% visualization of camera parameters estimation for NIKON D3x

clear; close all; clc;

DELTA_LAMBDA = 5;
RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

data_path = load('global_data_path.mat');

% load data
load(fullfile(data_path.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat'));

wavelengths = 380:DELTA_LAMBDA:780;

%% plot initial camera spectral sensitivity function

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on; grid on; box on;
plot(wavelengths, params.cam_spectra0(:, 1),...
     'color', RED, 'linewidth', 3, 'linestyle', ':');
plot(wavelengths, params.cam_spectra0(:, 2),...
     'color', GREEN, 'linewidth', 3, 'linestyle', ':');
plot(wavelengths, params.cam_spectra0(:, 3),...
     'color', BLUE, 'linewidth', 3, 'linestyle', ':');

xlim([380, 780]);
ylim([-0.05, 1.05]);

xlabel('Wavelength (nm)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Relative Spectral Sensitivity', 'fontsize', 24, 'fontname', 'times new roman');
 
hax = gca;
hax.XAxis.MinorTick = 'on';
hax.XAxis.MinorTickValues = 430:100:730;
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0.1:0.2:0.9;

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 22,...
         'TickLabelInterpreter', 'latex',...
         'XTick', 380:100:780,...
         'ytick', 0:0.2:1.2, 'ticklength', [0, 0],...
         'xminorgrid', 'on', 'yminorgrid', 'on');
     
%% plot estimated camera spectral sensitivity function

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on; grid on; box on;
plot(wavelengths, params.cam_spectra0(:, 1),...
     'color', RED, 'linewidth', 3, 'linestyle', ':');
plot(wavelengths, params.cam_spectra(:, 1),...
     'color', RED, 'linewidth', 3, 'linestyle', '-');
plot(wavelengths, params.cam_spectra0(:, 2),...
     'color', GREEN, 'linewidth', 3, 'linestyle', ':');
plot(wavelengths, params.cam_spectra(:, 2),...
     'color', GREEN, 'linewidth', 3, 'linestyle', '-');
plot(wavelengths, params.cam_spectra0(:, 3),...
     'color', BLUE, 'linewidth', 3, 'linestyle', ':');
plot(wavelengths, params.cam_spectra(:, 3),...
     'color', BLUE, 'linewidth', 3, 'linestyle', '-');

% phantom lines for adding a legend 
hline1 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', ':');
hline2 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', '-'); 

legend([hline1, hline2],...
       {' Initial Functions', ' Optimal Functions'},...
        'fontsize', 22, 'fontname', 'times new roman', 'box', 'off');

xlim([380, 780]);
ylim([-0.05, 1.05]);

xlabel('Wavelength (nm)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Relative Spectral Sensitivity', 'fontsize', 24, 'fontname', 'times new roman');

hax = gca;
hax.XAxis.MinorTick = 'on';
hax.XAxis.MinorTickValues = 430:100:730;
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0.1:0.2:0.9;

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 22,...
         'TickLabelInterpreter', 'latex',...
         'XTick', 380:100:780,...
         'ytick', 0:0.2:1.2, 'ticklength', [0, 0],...
         'xminorgrid', 'on', 'yminorgrid', 'on');
     
%% plot initial nonlinearity

noise_profiles = {'noise_calibration\NIKON_D3x\EXP8_ISO100_F4_55mm\noise_profile.mat',...
                  'noise_calibration\NIKON_D3x\EXP15_ISO200_F4_55mm\noise_profile.mat',...
                  'noise_calibration\NIKON_D3x\EXP30_ISO400_F4_55mm\noise_profile.mat'};

% generate a set of spectra with radiance from 0 to 1 w*sr^(-1)*m^(-2)
radiances = linspace(0, 0.25, 100)';
M = numel(radiances);
N = numel(wavelengths);
spectra = radiances .* ones(M, N) / N / DELTA_LAMBDA;
T = (1/8) * ones(M, 1); % 1/8s
linestyples = {'-', ':', '--'};
figure; hold on;
for i = 1:numel(noise_profiles)
    load(fullfile(data_path.path, noise_profiles{i}));
    g = noise_profile.g0_estimate;
    kappa0 = params.kappa0;
    cam_spectra0 = params.cam_spectra0;
    alpha0 = params.alpha0;
    beta0 = params.beta0;
    gamma0 = params.gamma0;
    responses = g .* real((kappa0 * DELTA_LAMBDA * diag(T) * spectra * cam_spectra0 + alpha0).^gamma0) + beta0;
    responses = max(min(responses, 1), 0);
    plot(radiances, responses(:, 1), 'color', RED, 'linestyle', linestyples{i});
    plot(radiances, responses(:, 2), 'color', GREEN, 'linestyle', linestyples{i});
    plot(radiances, responses(:, 3), 'color', BLUE, 'linestyle', linestyples{i});
end


