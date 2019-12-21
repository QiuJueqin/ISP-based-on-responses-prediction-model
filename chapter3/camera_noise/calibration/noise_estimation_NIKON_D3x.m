% get sigma_N^2 for various ISO levels for Nikon D3x

clear; close all; clc;

CAMERA_MODEL = 'NIKON_D3x';

data_config = parse_data_config;

n1 = 16;

params = {'EXP8_ISO100_F4_55mm',...
          'EXP15_ISO200_F4_55mm',...
          'EXP30_ISO400_F4_55mm',...
          'EXP60_ISO800_F4_55mm',...
          'EXP125_ISO1600_F4_55mm'};
folders = {'noise_calibration\NIKON_D3x\EXP8_ISO100_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP15_ISO200_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP30_ISO400_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP60_ISO800_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP125_ISO1600_F4_55mm'};
folders = fullfile(data_config.path, folders);

for i = 1:numel(folders)
    fprintf('============================================================\n');
    fprintf('Estimating sigma_N^2 for %s folder (%s).\n', params{i}, CAMERA_MODEL);
    fprintf('============================================================\n');
    tic;
    
    contents = dir(fullfile(folders{i}, 'various_illumination_sets\*.NEF'));
    raw_dirs = fullfile({contents.folder}, {contents.name});
    % only get .NEF file names for images captured under 1000lx
    % illumination set
    raw_dirs = raw_dirs(end-15 : end);
    assert(numel(raw_dirs) == n1);
    
    [~, sigmaN_estimate_map] = estimate_mu_sigmaN(raw_dirs);
    
    sigmaN_estimates.(params{i}) = sigmaN_estimate_map;
end

save_dir = fullfile(data_config.path, 'noise_calibration\NIKON_D3x\sigmaN_estimates.mat');
save(save_dir, 'sigmaN_estimates', '-v7.3');
