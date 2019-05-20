%% Preliminary experiment A:
% test dark current values w.r.t. exposure times for SONY ILCE7

clear; close all; clc;

CAMERA_MODEL = 'ILCE7';
INBIT = 12;
SQUARE_SIZE = 50;

data_path = load('global_data_path.mat');

%% extracting responses for ISO100, exposure times from 1/200s to 1/8s

folders = fullfile(data_path.path, 'response_prediction\preliminaries\ILCE7\ISO100_EXP200_to_8_F4_55mm\*.ARW');
contents = dir(folders);
profile_dir = '';
exposures = zeros(numel(contents), 1);
mean_values = zeros(numel(contents), 3);

for i = 1:numel(contents)
    raw_dir = fullfile(contents(i).folder, contents(i).name);
    profile_dir_tmp = findprofile(raw_dir, data_path.path);
    
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
    exposures(i) = info.DigitalCamera.ExposureTime;
    
    % extract mean responses from central ROI
    [height, width, ~] = size(converted_raw);
    roi = converted_raw(round(height/2 - SQUARE_SIZE) : round(height/2 + SQUARE_SIZE),...
                        round(width/2 - SQUARE_SIZE) : round(width/2 + SQUARE_SIZE),...
                        :);
	mean_values(i, :) = squeeze(mean(roi, [1, 2]))';
end

save_dir = fullfile(data_path.path, 'response_prediction\preliminaries\ILCE7\responses_vs_exposures_ISO100.mat');
save(save_dir, 'exposures', 'mean_values');

%% extracting responses for ISO800, exposure times from 1/200s to 1/8s

clearvars -except data_path SQUARE_SIZE

folders = fullfile(data_path.path, 'response_prediction\preliminaries\ILCE7\ISO800_EXP200_to_8_F4_55mm\*.ARW');
contents = dir(folders);
profile_dir = '';
exposures = zeros(numel(contents), 1);
mean_values = zeros(numel(contents), 3);

for i = 1:numel(contents)
    raw_dir = fullfile(contents(i).folder, contents(i).name);
    profile_dir_tmp = findprofile(raw_dir, data_path.path);
    
    % load the noise calibration profile if it does not exist in the
    % workspace
    if ~strcmpi(profile_dir, profile_dir_tmp)
        profile_dir = profile_dir_tmp;
        profile = load(profile_dir_tmp);
        fpn_template = uint16(profile.noise_profile.mu_dark_estimate);
        prnu_template = profile.noise_profile.K_estimate;
    end
    
    % read raw image
    matraw_params = {'inbit', 12, 'outbit', 'same', 'save', false,...
                     'fpntemplate', fpn_template,...
                     'prnutemplate', prnu_template};
	[converted_raw, info] = matrawread(raw_dir, matraw_params{:});
    
    % record exposure time
    exposures(i) = info.DigitalCamera.ExposureTime;
    
    % extract mean responses from central ROI
    [height, width, ~] = size(converted_raw);
    roi = converted_raw(round(height/2 - SQUARE_SIZE) : round(height/2 + SQUARE_SIZE),...
                        round(width/2 - SQUARE_SIZE) : round(width/2 + SQUARE_SIZE),...
                        :);
	mean_values(i, :) = squeeze(mean(roi, [1, 2]))';
end

save_dir = fullfile(data_path.path, 'response_prediction\preliminaries\ILCE7\responses_vs_exposures_ISO800.mat');
save(save_dir, 'exposures', 'mean_values');
