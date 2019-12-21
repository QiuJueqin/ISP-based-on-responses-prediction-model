%% Preliminary experiment B:
% test camera responses w.r.t. different capture settings for Nikon D3x

clear; close all; clc;

CAMERA_MODEL = 'NIKON_D3x';
INBIT = 14;
SQUARE_SIZE = 50;

data_config = parse_data_config;

folders = fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\combined_settings_1000lx\*.NEF');
contents = dir(folders);
profile_dir = '';
exposures = zeros(numel(contents), 1);
iso_levels = zeros(numel(contents), 1);
mean_values = zeros(numel(contents), 3);

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
    
    % read raw image
    matraw_params = {'inbit', INBIT, 'outbit', 'same', 'save', false,...
                     'fpntemplate', fpn_template,...
                     'prnutemplate', prnu_template};
	[converted_raw, info] = matrawread(raw_dir, matraw_params{:});
    
    % record exposure time and ISO level
    exposures(i) = info.DigitalCamera.ExposureTime;
    iso_levels(i) = info.DigitalCamera.ISOSpeedRatings;
    
    % extract mean responses from central ROI
    [height, width, ~] = size(converted_raw);
    roi = converted_raw(round(height/2 - SQUARE_SIZE) : round(height/2 + SQUARE_SIZE),...
                        round(width/2 - SQUARE_SIZE) : round(width/2 + SQUARE_SIZE),...
                        :);
	mean_values(i, :) = squeeze(mean(roi, [1, 2]))';
end

save_dir = fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_capture_settings.mat');
save(save_dir, 'exposures', 'iso_levels', 'mean_values');