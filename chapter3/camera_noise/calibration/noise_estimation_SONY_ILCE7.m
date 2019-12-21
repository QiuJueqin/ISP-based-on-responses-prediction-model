% get sigma_N^2 for various ISO levels for SONY ILCE7

clear; close all;

CAMERA_MODEL = 'ILCE7';
INBIT = 12;

data_config = parse_data_config;

n1 = 16;
matraw_params = {'inbit', INBIT, 'outbit', 'same'};

params = {'EXP8_ISO100_F4_55mm',...
          'EXP15_ISO200_F4_55mm',...
          'EXP30_ISO400_F4_55mm',...
          'EXP60_ISO800_F4_55mm',...
          'EXP125_ISO1600_F4_55mm'};
folders = {'noise_calibration\ILCE7\EXP8_ISO100_F4_55mm',...
           'noise_calibration\ILCE7\EXP15_ISO200_F4_55mm',...
           'noise_calibration\ILCE7\EXP30_ISO400_F4_55mm',...
           'noise_calibration\ILCE7\EXP60_ISO800_F4_55mm',...
           'noise_calibration\ILCE7\EXP125_ISO1600_F4_55mm'};
folders = fullfile(data_config.path, folders);

for i = 1:numel(folders)
    fprintf('============================================================\n');
    fprintf('Estimating sigma_N^2 for %s folder (%s).\n', params{i}, CAMERA_MODEL);
    fprintf('============================================================\n');
    tic;
    
    contents = dir(fullfile(folders{i}, 'various_illumination_sets\*.ARW'));
    raw_dirs = fullfile({contents.folder}, {contents.name});
    % only get .NEF file names for images captured under 1000lx
    % illumination set
    raw_dirs = raw_dirs(end-15 : end);
    assert(numel(raw_dirs) == n1);
    
    [~, sigmaN_estimate_map] = estimate_mu_sigmaN(raw_dirs, matraw_params{:});
    
    sigmaN_estimates.(params{i}) = sigmaN_estimate_map;
end

save_dir = fullfile(data_config.path, 'noise_calibration\ILCE7\sigmaN_estimates.mat');
save(save_dir, 'sigmaN_estimates', '-v7.3');
