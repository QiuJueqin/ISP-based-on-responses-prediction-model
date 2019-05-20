% camera raw responses prediction using PCA method for Nikon D3x
%
% c.f. Jiang. et.al. What is the Space of Spectral Sensitivity Functions
% for Digital Color Cameras? 

clear; close all; clc;

%% training

BIT = 14;
DELTA_LAMBDA = 5;

data_path = load('global_data_path.mat');

% read and validate training data
train_data_dirs = {'ISO100_EXP8_D65_DSG.mat',...
                   'ISO200_EXP15_D65_DSG.mat',...
                   'ISO400_EXP30_D65_DSG.mat',...
                   'ISO100_EXP8_LED_DSG.mat',...
                   'ISO200_EXP15_LED_DSG.mat',...
                   'ISO400_EXP30_LED_DSG.mat'};
train_data_dirs = fullfile(data_path.path,...
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

% colorimetric characterization training

responses = responses / (2^BIT-1);
xyz = spectra2colors(spectra, 380:5:780);
xyz = max(responses(:)) * xyz / max(xyz(:));
           
model = 'root13x3'; % color correction model
targetcolorspace = 'XYZ';

[matrix, scale, ~, errs_train] = ccmtrain(responses,...
                                          xyz,...
                                          'model', model,...
                                          'loss', 'ciedelab',...
                                          'bias', false,...
                                          'targetcolorspace', targetcolorspace);
ccprofile.model = model;
ccprofile.matrix = matrix;
ccprofile.scale = scale;

[params, loss, responses_pred] = params_estimate_pca(spectra, responses, g, T, DELTA_LAMBDA, ccprofile);
              
save_dir = fullfile(data_path.path,...
                    'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters_pca.mat');
save(save_dir, 'params', 'loss', 'responses_pred');

%% validation

clearvars -except params BIT DELTA_LAMBDA data_path

% set1: validation for different illuminant (CIE A)
% set2: validation for different objects (X-Rite Classic ColorChecker)
% set3: validation for different illuminant and different objects

val_set_names = {'diff_illuminant',...
                 'diff_objects',...
                 'diff_illuminant_objects'};
val_data_dirs_ = {{'ISO100_EXP10_D65_Classic.mat',...
                   'ISO200_EXP20_D65_Classic.mat',...
                   'ISO400_EXP40_D65_Classic.mat'},...
                  {'ISO100_EXP8_A_DSG.mat',...
                   'ISO200_EXP15_A_DSG.mat',...
                   'ISO400_EXP30_A_DSG.mat'},...
                  {'ISO100_EXP10_A_Classic.mat',...
                   'ISO200_EXP20_A_Classic.mat',...
                   'ISO400_EXP40_A_Classic.mat'}};
                    
for k = 1:3
    val_data_dirs = val_data_dirs_{k};
    val_data_dirs = fullfile(data_path.path,...
                             'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x',...
                             val_data_dirs);

    responses_val = [];
    spectra_val = [];
    g_val = [];
    T_val = [];

    for i = 1:numel(val_data_dirs)
        val_data_dir = val_data_dirs{i};
        res = load(val_data_dir);
        spectra_val = [spectra_val; res.result.spectra];
        responses_val = [responses_val; res.result.responses];
        g_val = [g_val; res.result.g];
        T_val = [T_val; res.result.T];
    end
    
    % chromatic characterization
    responses_val = responses_val / (2^BIT-1);
    xyz_val = spectra2colors(spectra_val, 380:5:780);
    xyz_val = max(responses_val(:)) * xyz_val / max(xyz_val(:));

    model = 'root13x3'; % color correction model
    targetcolorspace = 'XYZ';

    [matrix, scale, ~, errs_train] = ccmtrain(responses_val,...
                                              xyz_val,...
                                              'model', model,...
                                              'loss', 'ciedelab',...
                                              'bias', false,...
                                              'targetcolorspace', targetcolorspace);
    ccprofile.model = model;
    ccprofile.matrix = matrix;
    ccprofile.scale = scale;

    % responses prediction
    responses_val_pred = responses_predict_pca(params, spectra_val, g_val, T_val, DELTA_LAMBDA);

    % evaluation
    xyz_val = cc(responses_val,...
                 ccprofile.model,...
                 ccprofile.matrix,...
                 ccprofile.scale);
    lab_val = xyz2lab(100*xyz_val);
    
    % find an optimal brightness scale
    responses_val_pred_handle = @(x) x*responses_val_pred;
    responses_val_pred_handle = @(x) max(min(responses_val_pred_handle(x), 1), 0);
    xyz_val_pred_handle = @(x) cc(responses_val_pred_handle(x),...
                                  ccprofile.model,...
                                  ccprofile.matrix,...
                                  ccprofile.scale);
    lab_val_pred_handle = @(x) xyz2lab(100*xyz_val_pred_handle(x));
    loss_val_handle = @(x) mean(ciedelab(lab_val, lab_val_pred_handle(x)));
    scale = fminbnd(loss_val_handle, 0.5, 2);
    responses_val_pred = max(min(scale*responses_val_pred, 1), 0);

    xyz_val_pred = cc(responses_val_pred,...
                      ccprofile.model,...
                      ccprofile.matrix,...
                      ccprofile.scale);
    lab_val_pred = xyz2lab(100*xyz_val_pred);

    % record
    responses.(val_set_names{k}) = responses_val;
    responses_pred.(val_set_names{k}) = responses_val_pred;
    loss.(val_set_names{k}) = [ciedelab(lab_val, lab_val_pred),...
                               ciede00(lab_val, lab_val_pred)];
    
    clearvars -except BIT DELTA_LAMBDA data_path ccprofile params...
                      val_set_names val_data_dirs_...
                      responses responses_pred loss
end

save_dir = fullfile(data_path.path,...
                    'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\validation_pca.mat');
save(save_dir, 'responses', 'responses_pred', 'loss');