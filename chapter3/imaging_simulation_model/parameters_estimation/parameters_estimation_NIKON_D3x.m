% parameters estimation of imaging simulation model for Nikon D3x

clear; close all; clc;

BIT = 14;
DELTA_LAMBDA = 5;
REG_FACTOR = 0.06;
SMOOTH_THRESHOLD = 4;
WAVELENGTH_RANGE = [380, 780];

data_config = parse_data_config;

% read and validate training data
train_data_dirs = {'ISO100_EXP8_D65_DSG.mat',...
                   'ISO200_EXP15_D65_DSG.mat',...
                   'ISO400_EXP30_D65_DSG.mat',...
                   'ISO100_EXP8_LED_DSG.mat',...
                   'ISO200_EXP15_LED_DSG.mat',...
                   'ISO400_EXP30_LED_DSG.mat'};
train_data_dirs = fullfile(data_config.path,...
                           'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x',...
                           train_data_dirs);

responses = [];
spectra = [];
g = [];
T = [];

for i = 1:numel(train_data_dirs)
    train_data_dir = train_data_dirs{i};
    res = load(train_data_dir);
    flags = res.result.responses_flags & res.result.spectra_flags;
    spectra = [spectra; res.result.spectra(flags, :)];
    responses = [responses; res.result.responses(flags, :)];
    g = [g; res.result.g(flags, :)];
    T = [T; res.result.T(flags, :)];
end

%% colorimetric characterization training

responses = responses / (2^BIT-1);
xyz = spectra2colors(spectra, 380:5:780);
xyz = max(responses(:)) * xyz / max(xyz(:));
           
model = 'root13x3'; % color correction model
targetcolorspace = 'XYZ';

[matrix, scale, ~, errs_train] = ccmtrain(responses,...
                                          xyz,...
                                          'model', model,...
                                          'bias', false,...
                                          'targetcolorspace', targetcolorspace);
ccprofile.model = model;
ccprofile.matrix = matrix;
ccprofile.scale = scale;

%% training

[params, loss, responses_pred] = params_estimate(spectra, responses, g, T, DELTA_LAMBDA, ccprofile,...
                                                 REG_FACTOR, SMOOTH_THRESHOLD);
params.wavelengths = WAVELENGTH_RANGE(1):DELTA_LAMBDA:WAVELENGTH_RANGE(2);

save_dir = fullfile(data_config.path,...
                    'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
save(save_dir, 'params', 'loss', 'responses_pred');
