% comparisons of the estimated camera spectral sensitivity functions for
% the proposed method, PCA method, and radial basis functions network
% (RBFN) method

%% Nikon D3x

clear; close all; clc;

DELTA_LAMBDA = 5;
RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

data_path = load('global_data_path.mat');

% load data
params_proposed = load(fullfile(data_path.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat'));
params_pca = load(fullfile(data_path.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters_pca.mat'));
params_rbfn = load(fullfile(data_path.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters_rbfn.mat'));

wavelengths = 380:DELTA_LAMBDA:780;
wavelengths_small = 400:DELTA_LAMBDA:720;

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on; grid on; box on;
colors = {RED, GREEN, BLUE};
for k = 1:3
	plot(wavelengths, params_proposed.params.cam_spectra(:, k),...
         'color', colors{k}, 'linewidth', 3, 'linestyle', '-');
    plot(wavelengths_small, params_pca.params.cam_spectra(:, k),...
         'color', colors{k}, 'linewidth', 3, 'linestyle', ':');
    plot(wavelengths_small, params_rbfn.params.cam_spectra(:, k),...
         'color', colors{k}, 'linewidth', 3, 'linestyle', '--');
end

% phantom lines for adding a legend 
hline1 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', '-');
hline2 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', ':');
hline3 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', '--');

xlim([380, 780]);
ylim([-0.05, 1.05]);

legend([hline1, hline2, hline3],...
       {' Proposed',...
        ' PCA',...
        ' RBFN'},...
        'fontname', 'times new roman', 'fontsize', 20, 'box', 'off');
    
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


%% SONY ILCE7

clearvars -except DELTA_LAMBDA RED GREEN BLUE data_path

% load data
params_proposed = load(fullfile(data_path.path, 'imaging_simulation_model\parameters_estimation\responses\ILCE7\camera_parameters.mat'));
params_pca = load(fullfile(data_path.path, 'imaging_simulation_model\parameters_estimation\responses\ILCE7\camera_parameters_pca.mat'));
params_rbfn = load(fullfile(data_path.path, 'imaging_simulation_model\parameters_estimation\responses\ILCE7\camera_parameters_rbfn.mat'));

wavelengths = 380:DELTA_LAMBDA:780;
wavelengths_small = 400:DELTA_LAMBDA:720;

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on; grid on; box on;
colors = {RED, GREEN, BLUE};
for k = 1:3
	plot(wavelengths, params_proposed.params.cam_spectra(:, k),...
         'color', colors{k}, 'linewidth', 3, 'linestyle', '-');
    plot(wavelengths_small, params_pca.params.cam_spectra(:, k),...
         'color', colors{k}, 'linewidth', 3, 'linestyle', ':');
    plot(wavelengths_small, params_rbfn.params.cam_spectra(:, k),...
         'color', colors{k}, 'linewidth', 3, 'linestyle', '--');
end

% phantom lines for adding a legend 
hline1 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', '-');
hline2 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', ':');
hline3 = plot(0, 0, 'color', [.5, .5, .5], 'linewidth', 3, 'linestyle', '--');

xlim([380, 780]);
ylim([-0.05, 1.05]);

legend([hline1, hline2, hline3],...
       {' Proposed',...
        ' PCA',...
        ' RBFN'},...
        'fontname', 'times new roman', 'fontsize', 20, 'box', 'off');
    
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
