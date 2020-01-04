clear; close all; clc;

ISO = 100;

data_config = parse_data_config;
camera_config = parse_camera_config('SONY_ILCE7', {'responses', 'gains'});
gains = iso2gains(ISO, camera_config.gains);

% generate standard gamut
std_gamut = standard_gamut_calib(camera_config.responses.params, gains);

save_dir = fullfile(data_config.path,...
                    'white_balance_correction\gamut_mapping\SONY_ILCE7\std_gamut.mat');
save(save_dir, 'std_gamut');