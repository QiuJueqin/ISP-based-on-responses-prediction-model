clear; close all; clc;

ISO = 100;

data_path = load('global_data_path.mat');

iso_profile_dir = fullfile(data_path.path,...
                           'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\gains_profile.mat');
iso_profile = load(iso_profile_dir);

gains = iso2gains(ISO, iso_profile);

% load parameters of imaging simulation model
params_dir = fullfile(data_path.path,...
                      'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
params = load(params_dir);

ocp_params = find_ocp_params(params.params, gains);

save_dir = fullfile(data_path.path,...
                    'white_balance_correction\neutral_point_statistics\NIKON_D3x\ocp_params.mat');
save(save_dir, 'ocp_params');
