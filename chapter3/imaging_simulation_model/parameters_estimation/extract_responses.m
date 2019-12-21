function extract_responses(raws_dir, varargin)
% EXTRACT_RESPONSES extracts camera raw responses from images by
% calculating mean or median values in a rectangle ROI (specified by the
% user in a interactive way).
%
% INPUTS:
% raws_dir:             directory that contains raw image files.
% varargin:             any name-value paramter(s) supported by MatRaw
%
% OUTPUTS:
% None (the extracted raw responses and other parameters will be packaged
% into a struct named 'result' and saved in a .mat files).
% result.responses:     M*3 matrix for the extracted raw responses where M
%                       is the number of color sample (also the number of
%                       raw files).
% result.responses_med: same as 'result.responses' but calculated using
%                       median().
% result.variances:     variances within rectangle ROIs.
% result.g:             estimated g0 for color samples.
% result.T:             exposure times for color samples.
% result.responses_flags:  boolean vector to indicate which responses are
%                          useable and which are not.

SATURATION_THRESHOLD = 0.95;
CV_THRESHOLD = 0.1;
BOX_SIZE = 50;
BOX_LINEWIDTH = 3;

data_config = parse_data_config;

if nargin < 2 || isempty(varargin)
    matraw_params = {'inbit', 14, 'outbit', 'same', 'save', false,...
                     'fpntemplate', [], 'prnutemplate', []};
else
    matraw_params = varargin;
end

contents = dir(raws_dir);
assert(numel(contents)>1);

% create a new folder to store thumnail images
[parent_dir, dir_name] = fileparts(fileparts(raws_dir));
thumbnails_dir = fullfile(parent_dir, [dir_name, '_thumbnails']);
mkdir(thumbnails_dir);

% M*3 response matrix
responses = zeros(numel(contents), 3);
responses_med = zeros(numel(contents), 3);

% M*3 gains matrix
g = zeros(numel(contents), 3);

% M*1 exposure times matrix
T = zeros(numel(contents), 1);

% an indicator vector where 1 means the response is appropriate and 0 means
% there are some problems for the response (e.g., saturation, capture
% parameter mismatching, large variance, etc.)
responses_flags = ones(numel(contents), 1);

% M*3 variance matrix (only for sample filtration)
variances = zeros(numel(contents), 3);

profile_dir = '';
for i = 1:numel(contents)
    raw_dir = fullfile(contents(i).folder, contents(i).name);
    
    profile_dir_tmp = findprofile(raw_dir, data_config.path);
    % load the noise calibration profile if it does not exist in the
    % workspace
    if ~strcmpi(profile_dir, profile_dir_tmp)
        profile_dir = profile_dir_tmp;
        profile = load(profile_dir_tmp);
        fpn_template = uint16(profile.noise_profile.mu_dark_estimate);
        prnu_template = profile.noise_profile.K_estimate;
    end

    matraw_params(8) = fpn_template;
    matraw_params(10) = prnu_template;
    
    [converted_raw, info] = matrawread(raw_dir, matraw_params{:});
    
    % capture params must be same for all raw images to be concatenated
    capture_params = [info.DigitalCamera.ExposureTime,...
                      info.DigitalCamera.FNumber,...
                      info.DigitalCamera.ISOSpeedRatings,...
                      info.DigitalCamera.FocalLength];
    if ~exist('reference_capture_params', 'var')
        reference_capture_params = capture_params;
    else
        if ~isequal(reference_capture_params, capture_params)
            responses_flags(i) = 0;
        end
    end
    
    T(i) = capture_params(1);
    
    % check if the ISO of current image is identical to the reference,
    % otherwise 'g0_estimate' in the profile will be unsuitable for current
    % image
    reference_iso = regexp(profile.noise_profile.params, 'ISO(\d+)_', 'tokens');
    reference_iso = str2double(reference_iso{1}{1});
    if reference_iso ~= capture_params(3)
        responses_flags(i) = 0;
    else
        g(i, :) = profile.noise_profile.g0_estimate;
    end
    
    % get a rectangle ROI to extract raw response
    tmp = (double(converted_raw) / double(max(converted_raw(:)))) .^ 0.45;
    if i == 1
        txt_dir = fullfile(contents(i).folder, 'roibox.txt');
        if exist(txt_dir, 'file')
            % read .txt files to get box coordinates
            roi_box = dlmread(txt_dir);
        else
            % otherwise ask user to draw a rectangle ROI
            hfig = figure;
            imshow(tmp);
            zoom(4);
            [h, w, ~] = size(tmp);
            pos = [round(w/2 - BOX_SIZE/2),...
                   round(h/2 - BOX_SIZE/2),...
                   BOX_SIZE,...
                   BOX_SIZE];
            hroi = drawrectangle('Label', 'ROI',...
                                 'position', pos,...
                                 'AspectRatio', 1,...
                                 'FixedAspectRatio', true,...
                                 'InteractionsAllowed', 'translate');
            set(hfig, 'Name', 'Adjust the ROI rectangles and click ''Continue'' to finish');
            fig_size = get(hfig, 'Position');
            hbutton = uicontrol(hfig,...
                               'Position', [fig_size(3)-120 20 100 40],...
                               'String', 'Continue',...
                               'Callback', @pushbutton_callback);
            uiwait(hfig);
            roi_box = round(hroi.Position);
            pause(1);
            close(hfig);
            dlmwrite(txt_dir, roi_box);
        end
        fprintf('A %d*%d rectangle ROI is selected.\n', roi_box(3), roi_box(4));
    end
    
    roi = double(converted_raw(roi_box(2):roi_box(2)+roi_box(4)-1,...
                               roi_box(1):roi_box(1)+roi_box(3)-1,...
                               :));

	response = squeeze(mean(roi, [1, 2]))';
    response_med = squeeze(median(roi, [1, 2]))';
    variance = squeeze(var(roi, [], [1, 2]))';
    responses(i, :) = response;
    responses_med(i, :) = response_med;
    variances(i, :) = variance;
    
    % check if responses are saturated, or the dispersion within ROI is too
    % large
	b = matraw_params{find(strcmpi(matraw_params, 'inbit')) + 1};
    saturation = 2^b - 1;
    cv = sqrt(variance) ./ response; % coefficient of variation
    if max(roi(:)) > SATURATION_THRESHOLD*saturation || max(cv) > CV_THRESHOLD
        responses_flags(i) = 0;
    end
    
    % create and save a thumbnail image
    tmp = tmp(roi_box(2) - 6*roi_box(4):roi_box(2) + 6*roi_box(4),...
              roi_box(1) - 6*roi_box(3):roi_box(1) + 6*roi_box(3),...
              :);
    
	% draw a rectangle box
	tmp(6*roi_box(4):7*roi_box(4), 6*roi_box(3):6*roi_box(3)+BOX_LINEWIDTH, :) = 0;
    tmp(6*roi_box(4):7*roi_box(4), 7*roi_box(3)-BOX_LINEWIDTH:7*roi_box(3), :) = 0;
    tmp(6*roi_box(4):6*roi_box(4)+BOX_LINEWIDTH, 6*roi_box(3):7*roi_box(3), :) = 0;
    tmp(7*roi_box(4)-BOX_LINEWIDTH:7*roi_box(4), 6*roi_box(3):7*roi_box(3), :) = 0;

    [~, raw_name] = fileparts(raw_dir);
    thumbnail_dir = fullfile(thumbnails_dir, [raw_name, '.png']);
    imwrite(tmp, thumbnail_dir);
    
    fprintf('%d/%d done.\n', i, numel(contents));
end

result.responses_flags = responses_flags;
result.g = g;
result.T = T;
result.responses = responses;
result.responses_med = responses_med;
result.variances = variances;

save_dir = fullfile(parent_dir, [dir_name, '.mat']);
save(save_dir, 'result');

end


function pushbutton_callback(hObject, eventdata, handles)
%%
% callback function of the figure
uiresume;
set(hObject, 'Visible', 'off');
end