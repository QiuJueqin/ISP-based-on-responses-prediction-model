function profile_dir = findprofile(raw_dir, data_path)
% FINDPROFILE automatically determines the directory of the noise
% calibration profile for the input raw image.
%
% INPUTS:
% raw_dir:      path of raw file
% data_path:    root directory where all data are stored
%
% OUTPUTS:
% profile_dir:  path of the corresponding noise calibration file

% get all supported camera models
tmp = dir(fullfile(data_path, 'noise_calibration'));
camera_models = cell(0);
for i = 1:numel(tmp)
    if tmp(i).isdir && ~strcmpi(tmp(i).name, '.') && ~strcmpi(tmp(i).name, '..')
    	 camera_models{end+1} = tmp(i).name;
    end
end

% get all supported capture settings
info = getrawinfo(raw_dir);
current_camera_model = strrep(strrep(info.Model, ' ', '_'), '-', '');
if any(strcmpi(camera_models, current_camera_model))
    tmp = dir(fullfile(data_path, 'noise_calibration', current_camera_model));
    exposures = []; 
    iso_levels = []; 
    f_numbers = []; 
    focus_dist = [];
    for i = 1:numel(tmp)
        if tmp(i).isdir && ~strcmpi(tmp(i).name, '.') && ~strcmpi(tmp(i).name, '..')
             strs = regexp(tmp(i).name, 'EXP(\d+)_ISO(\d+)_F(\d+)_(\d+)mm', 'tokens');
             exposures(end+1) = str2double(strs{1}{1});
             iso_levels(end+1) = str2double(strs{1}{2});
             f_numbers(end+1) = str2double(strs{1}{3});
             focus_dist(end+1) = str2double(strs{1}{4});
        end
    end
else
    error('Camera model %s has no noise calibration profile.');
end

% find matched profile
settings = [iso_levels; exposures; f_numbers; focus_dist];
current_setting = [info.DigitalCamera.ISOSpeedRatings;...
                   1/info.DigitalCamera.ExposureTime;...
                   info.DigitalCamera.FNumber;...
                   info.DigitalCamera.FocalLength];
               
% Different weights for ISO, exposure, f-number, and focus distance.
% Comparison for exposures will be performed only if there are multiple
% matched ISO levels, analogously for f-number and focus distance.
diff = [1E3, 1E2, 1E-3, 1E-6] * abs(settings - current_setting);
[min_diff, idx] = min(diff);
matched_setting = sprintf('EXP%d_ISO%d_F%d_%dmm',...
                          exposures(idx),...
                          iso_levels(idx),...
                          f_numbers(idx),...
                          focus_dist(idx));

if min_diff > 0
    fprintf('Profile for current image (EXP1/%ds, ISO%d, F%d) is not found. Use ''%s'' instead.\n',...
            current_setting([2, 1, 3]), matched_setting);
end
profile_dir = fullfile(data_path, 'noise_calibration', current_camera_model, matched_setting, 'noise_profile.mat');
assert(exist(profile_dir, 'file') == 2);
