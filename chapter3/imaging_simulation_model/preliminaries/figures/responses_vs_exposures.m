%% plot camera responses (from dark frames) w.r.t. exposure times for NIKON D3x

clear; close all; clc;

RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

config = parse_data_config;

% load data captured under ISO100
load(fullfile(config.data_path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_exposures_ISO100.mat'));

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hax = axes(hfig, 'position', [.125 .15 .8 .8]);

hline1 = semilogx(exposures, mean_values(:, 1), 'color', RED, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
     
hold on;     
hline2 = semilogx(exposures, mean_values(:, 2), 'color', GREEN, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline3 = semilogx(exposures, mean_values(:, 3), 'color', BLUE, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);

% load data captured under ISO800
load(fullfile(config.data_path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_exposures_ISO800.mat'));

hline4 = semilogx(exposures, mean_values(:, 1), 'color', RED, 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
hline5 = semilogx(exposures, mean_values(:, 2), 'color', GREEN, 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline6 = semilogx(exposures, mean_values(:, 3), 'color', BLUE, 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);
     
grid on; box on;

xlim([0.0045, 0.11]);
ylim([0, 6]);

legend([hline1, hline2, hline3, hline4, hline5, hline6],...
    {' Red Channel, ISO100', ' Green Channel, ISO100', ' Blue Channel, ISO100',...
     ' Red Channel, ISO800', ' Green Channel, ISO800', ' Blue Channel, ISO800'},...
     'fontsize', 18, 'fontname', 'times new roman', 'box', 'off');
 
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0.5:1:5.5;

xticklabels = cellfun(@(x)sprintf('$\\frac{1}{%d}$', x), num2cell(1./exposures), 'UniformOutput', false);

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 22,...
         'TickLabelInterpreter', 'latex',...
         'XTick', exposures, 'XTickLabel', xticklabels,...
         'ytick', 0:6, 'ticklength', [0, 0],...
         'xminorgrid', 'off', 'yminorgrid', 'on');
     
xlabel('Exposure Time (s)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Raw Response (in 14-bit)', 'fontsize', 26, 'fontname', 'times new roman');
     

%% plot camera responses (from dark frames) w.r.t. exposure times for SONY ILCE7

clearvars -except RED GREEN BLUE data_path

% load data captured under ISO100
load(fullfile(config.data_path, 'response_prediction\preliminaries\ILCE7\responses_vs_exposures_ISO100.mat'));

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hax = axes(hfig, 'position', [.125 .15 .8 .8]);

hline1 = semilogx(exposures, mean_values(:, 1), 'color', RED, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
     
hold on;     
hline2 = semilogx(exposures, mean_values(:, 2), 'color', GREEN, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline3 = semilogx(exposures, mean_values(:, 3), 'color', BLUE, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);

% load data captured under ISO800
load(fullfile(config.data_path, 'response_prediction\preliminaries\ILCE7\responses_vs_exposures_ISO800.mat'));

hline4 = semilogx(exposures, mean_values(:, 1), 'color', RED, 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
hline5 = semilogx(exposures, mean_values(:, 2), 'color', GREEN, 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline6 = semilogx(exposures, mean_values(:, 3), 'color', BLUE, 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);
     
grid on; box on;

xlim([0.0045, 0.11]);
ylim([-0.05, 1.2]);

legend([hline1, hline2, hline3, hline4, hline5, hline6],...
    {' Red Channel, ISO100', ' Green Channel, ISO100', ' Blue Channel, ISO100',...
     ' Red Channel, ISO800', ' Green Channel, ISO800', ' Blue Channel, ISO800'},...
     'fontsize', 18, 'fontname', 'times new roman', 'box', 'off');
 
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0.1:0.2:1.1;

xticklabels = cellfun(@(x)sprintf('$\\frac{1}{%d}$', x), num2cell(1./exposures), 'UniformOutput', false);

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 22,...
         'TickLabelInterpreter', 'latex',...
         'XTick', exposures, 'XTickLabel', xticklabels,...
         'ytick', 0:0.2:1.2, 'ticklength', [0, 0],...
         'xminorgrid', 'off', 'yminorgrid', 'on');
     
xlabel('Exposure Time (s)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Raw Response (in 12-bit)', 'fontsize', 26, 'fontname', 'times new roman');
     