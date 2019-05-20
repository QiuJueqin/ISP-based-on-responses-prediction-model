function concat_tensor = raws2tensor(raw_dirs, varargin)
% RAWS2TENSOR reads .NEF files given in raw_dirs and concatenates into a
% (N+1)-dim tensor, where N is the number of dims of each converted raw
% image.
%
% INPUTS:
% raw_dirs:         a cell specifying the .NEF file names (absolute dir)
% varargin:         any name-value paramter(s) supported by MatRaw
%
% OUTPUTS:
% concat_tensor:    concatenated tensor in uint16 data type
%
% Example: 
% if raw_dirs = {'1.NEF', '2.NEF', '3.NEF', '4.NEF'} and each converted raw
% image is of size 3000*4000*3, then 'concat_tensor' will be a
% 3000*4000*3*4 tensor.

variance_threshold = 5; 
N = numel(raw_dirs);
assert(N > 1);

if nargin < 2 || isempty(varargin)
    matraw_params = {'outbit', 'same', 'save', false};
else
    matraw_params = varargin;
end

concat_tensor = [];
for i = 1:N
    raw_dir = raw_dirs{i};
    [converted_raw, info] = matrawread(raw_dir, matraw_params{:});
    
    % capture params must be same for all raw images to be concatenated
    capture_params = [info.DigitalCamera.ExposureTime,...
                      info.DigitalCamera.FNumber,...
                      info.DigitalCamera.ISOSpeedRatings,...
                      info.DigitalCamera.FocalLength];
	if ~exist('reference_capture_params', 'var')
        reference_capture_params = capture_params;
    else
        assert(isequal(reference_capture_params, capture_params),...
               'Capture parameter for ''%s'' is invalid.', raw_dir);
    end
    
    % concatenate in 4th dim
    concat_tensor = cat(4, concat_tensor, converted_raw);
end

% determine if the intra-variance among frames exceeds a threshold
glocal_means = squeeze(mean(concat_tensor, [1, 2, 3]));
if var(glocal_means) > variance_threshold
    warning('The intra-variance (%.2f) for ''%s'' to ''%s'' exceeds the threshold.',...
            var(glocal_means), raw_dirs{1}, raw_dirs{end});
end
