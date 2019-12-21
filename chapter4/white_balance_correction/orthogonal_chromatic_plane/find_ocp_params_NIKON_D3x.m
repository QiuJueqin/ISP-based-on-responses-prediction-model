clear; close all; clc;

ISO = 100;

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x', {'responses', 'gains'});

gains = iso2gains(ISO, camera_config.gains);
ocp_params = find_ocp_params(camera_config.responses.params, gains);

save_dir = fullfile(data_config.path,...
                    'white_balance_correction\neutral_point_statistics\NIKON_D3x\ocp_params.mat');
save(save_dir, 'ocp_params');
