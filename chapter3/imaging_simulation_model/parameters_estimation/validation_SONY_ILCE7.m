clear; close all; clc;

BIT = 12;
DELTA_LAMBDA = 5;

config = parse_data_config;

% load parameters of imaging simulation model
params_dir = fullfile(config.data_path,...
                      'imaging_simulation_model\parameters_estimation\responses\ILCE7\camera_parameters.mat');
params = load(params_dir);

%% validation

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
    val_data_dirs = fullfile(config.data_path,...
                             'imaging_simulation_model\parameters_estimation\responses\ILCE7',...
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
    
    % record
    responses.(val_set_names{k}) = responses_val;
    
    % responses prediction with optimal parameters
    responses_val_pred = responses_predict(params.params, spectra_val, g_val, T_val, DELTA_LAMBDA);
    
    kappa0 = params.params.kappa0;
    cam_spectra0 = params.params.cam_spectra0;
    alpha0 = params.params.alpha0;
    beta0 = params.params.beta0;
    gamma0 = params.params.gamma0;
    
    % responses prediction with camera spectral sensitivity functions only
    responses_val_pred_lin = g_val .* (kappa0 * DELTA_LAMBDA * diag(T_val) * spectra_val * cam_spectra0);
    responses_val_pred_lin = max(min(responses_val_pred_lin, 1), 0);
    
    % responses prediction with nonlinear function
    responses_val_pred_nonl = g_val .* real((kappa0 * DELTA_LAMBDA * diag(T_val) * spectra_val * cam_spectra0 + alpha0).^gamma0) + beta0;
    responses_val_pred_nonl = max(min(responses_val_pred_nonl, 1), 0);
    
    % evaluation for optimal parameters
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
    responses_pred.(val_set_names{k}) = responses_val_pred;
    loss.(val_set_names{k}) = [ciedelab(lab_val, lab_val_pred),...
                               ciede00(lab_val, lab_val_pred)];
    
    % evaluation for camera spectral sensitivity functions only
    xyz_val_pred_lin = cc(responses_val_pred_lin,...
                          ccprofile.model,...
                          ccprofile.matrix,...
                          ccprofile.scale);
    lab_val_pred_lin = xyz2lab(100*xyz_val_pred_lin);
    responses_pred_lin.(val_set_names{k}) = responses_val_pred_lin;
    loss_lin.(val_set_names{k}) = [ciedelab(lab_val, lab_val_pred_lin),...
                                   ciede00(lab_val, lab_val_pred_lin)];
    
    % evaluation for nonlinear function
    xyz_val_pred_nonl = cc(responses_val_pred_nonl,...
                           ccprofile.model,...
                           ccprofile.matrix,...
                           ccprofile.scale);
    lab_val_pred_nonl = xyz2lab(100*xyz_val_pred_nonl);
    responses_pred_nonl.(val_set_names{k}) = responses_val_pred_nonl;
    loss_nonl.(val_set_names{k}) = [ciedelab(lab_val, lab_val_pred_nonl),...
                                    ciede00(lab_val, lab_val_pred_nonl)];
    
    clearvars -except BIT DELTA_LAMBDA data_path ccprofile params...
                      val_set_names val_data_dirs_ responses...
                      responses_pred loss...
                      responses_pred_lin loss_lin...
                      responses_pred_nonl loss_nonl
end

save_dir = fullfile(config.data_path,...
                    'imaging_simulation_model\parameters_estimation\responses\ILCE7\validation.mat');
save(save_dir, 'responses',...
               'responses_pred', 'loss',...
               'responses_pred_lin', 'loss_lin',...
               'responses_pred_nonl', 'loss_nonl');
