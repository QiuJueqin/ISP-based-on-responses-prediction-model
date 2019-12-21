%% Preliminary experiment B:
% test dark current values w.r.t. ISO levels for Nikon D3x

clear; close all; clc;

CAMERA_MODEL = 'NIKON_D3x';
INBIT = 14;
SQUARE_SIZE = 50;

data_config = parse_data_config;

%% extracting responses for exposure times 1/8s, ISO levels from 100 to 1600

folders = fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\EXP8_ISO100_to_1600_F4_55mm\*.NEF');
contents = dir(folders);
profile_dir = '';
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
    
    % record exposure time
    iso_levels(i) = info.DigitalCamera.ISOSpeedRatings;
    
    % extract mean responses from central ROI
    [height, width, ~] = size(converted_raw);
    roi = converted_raw(round(height/2 - SQUARE_SIZE) : round(height/2 + SQUARE_SIZE),...
                        round(width/2 - SQUARE_SIZE) : round(width/2 + SQUARE_SIZE),...
                        :);
	mean_values(i, :) = squeeze(mean(roi, [1, 2]))';
end

save_dir = fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_iso_EXP8.mat');
save(save_dir, 'iso_levels', 'mean_values');

%% extracting responses for exposure times 1/60s, ISO levels from 100 to 1600

clearvars -except data_path SQUARE_SIZE

folders = fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\EXP60_ISO100_to_1600_F4_55mm\*.NEF');
contents = dir(folders);
profile_dir = '';
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
    matraw_params = {'inbit', 14, 'outbit', 'same', 'save', false,...
                     'fpntemplate', fpn_template,...
                     'prnutemplate', prnu_template};
	[converted_raw, info] = matrawread(raw_dir, matraw_params{:});
    
    % record exposure time
    iso_levels(i) = info.DigitalCamera.ISOSpeedRatings;
    
    % extract mean responses from central ROI
    [height, width, ~] = size(converted_raw);
    roi = converted_raw(round(height/2 - SQUARE_SIZE) : round(height/2 + SQUARE_SIZE),...
                        round(width/2 - SQUARE_SIZE) : round(width/2 + SQUARE_SIZE),...
                        :);
	mean_values(i, :) = squeeze(mean(roi, [1, 2]))';
end

save_dir = fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_iso_EXP60.mat');
save(save_dir, 'iso_levels', 'mean_values');
