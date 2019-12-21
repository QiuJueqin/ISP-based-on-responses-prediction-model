%% plot camera responses (from dark frames) w.r.t. ISO levels for NIKON D3x

clear; close all; clc;

RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

data_config = parse_data_config;

% load data captured under ISO100
load(fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_iso_EXP60.mat'));

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 17]);
hax = axes(hfig, 'position', [.125 .2 .8 .74]);

hline1 = semilogx(iso_levels, mean_values(:, 1), 'color', RED, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
     
hold on;     
hline2 = semilogx(iso_levels, mean_values(:, 2), 'color', GREEN, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline3 = semilogx(iso_levels, mean_values(:, 3), 'color', BLUE, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);

% load data captured under ISO800
load(fullfile(data_config.path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_iso_EXP8.mat'));

hline4 = semilogx(iso_levels, mean_values(:, 1), 'color', RED, 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
hline5 = semilogx(iso_levels, mean_values(:, 2), 'color', GREEN, 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline6 = semilogx(iso_levels, mean_values(:, 3), 'color', BLUE, 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);
     
grid on; box on;

xlim([88, 1800]);
ylim([0, 6]);

legend([hline1, hline2, hline3, hline4, hline5, hline6],...
    {' Red Channel, 1/60s', ' Green Channel, 1/60s', ' Blue Channel, 1/60s',...
     ' Red Channel, 1/8s', ' Green Channel, 1/8s', ' Blue Channel, 1/8s'},...
     'fontsize', 18, 'fontname', 'times new roman', 'box', 'off');
 
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0.5:1:5.5;

xticklabels = num2cell(iso_levels);

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 24,...
         'TickLabelInterpreter', 'latex',...
         'XTick', iso_levels, 'XTickLabel', xticklabels,...
         'XTickLabelRotation', 45,...
         'ytick', 0:6, 'ticklength', [0, 0],...
         'xminorgrid', 'off', 'yminorgrid', 'on');
     
xlabel('ISO Level', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Raw Response (in 14-bit)', 'fontsize', 26, 'fontname', 'times new roman');
     

%% plot camera responses (from dark frames) w.r.t. ISO levels for SONY ILCE7

clearvars -except RED GREEN BLUE data_config

% load data captured under ISO100
load(fullfile(data_config.path, 'response_prediction\preliminaries\ILCE7\responses_vs_iso_EXP60.mat'));

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 17]);
hax = axes(hfig, 'position', [.125 .2 .8 .74]);

hline1 = semilogx(iso_levels, mean_values(:, 1), 'color', RED, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
     
hold on;     
hline2 = semilogx(iso_levels, mean_values(:, 2), 'color', GREEN, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline3 = semilogx(iso_levels, mean_values(:, 3), 'color', BLUE, 'linestyle', ':', 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);

% load data captured under ISO800
load(fullfile(data_config.path, 'response_prediction\preliminaries\ILCE7\responses_vs_iso_EXP8.mat'));

hline4 = semilogx(iso_levels, mean_values(:, 1), 'color', RED, 'marker', 'o',...
                  'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
hline5 = semilogx(iso_levels, mean_values(:, 2), 'color', GREEN, 'marker', 'o',...
                  'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
hline6 = semilogx(iso_levels, mean_values(:, 3), 'color', BLUE, 'marker', 'o',...
                  'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);
     
grid on; box on;

xlim([88, 1800]);
ylim([-0.05, 1.4]);

legend([hline1, hline2, hline3, hline4, hline5, hline6],...
    {' Red Channel, 1/60s', ' Green Channel, 1/60s', ' Blue Channel, 1/60s',...
     ' Red Channel, 1/8s', ' Green Channel, 1/8s', ' Blue Channel, 1/8s'},...
     'fontsize', 18, 'fontname', 'times new roman', 'box', 'off');
 
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0.1:0.2:1.3;

xticklabels = num2cell(iso_levels);

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 24,...
         'TickLabelInterpreter', 'latex',...
         'XTick', iso_levels, 'XTickLabel', xticklabels,...
         'XTickLabelRotation', 45,...
         'ytick', 0:0.2:1.4, 'ticklength', [0, 0],...
         'xminorgrid', 'off', 'yminorgrid', 'on');
     
xlabel('ISO Level', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Raw Response (in 12-bit)', 'fontsize', 26, 'fontname', 'times new roman');
     