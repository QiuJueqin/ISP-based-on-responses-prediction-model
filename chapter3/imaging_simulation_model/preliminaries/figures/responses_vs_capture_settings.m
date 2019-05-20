%% 
% plot camera responses (from dark frames) w.r.t. different capture 
% settings for NIKON D3x

clear; close all; clc;

RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

data_path = load('global_data_path.mat');

% load data
load(fullfile(data_path.path, 'response_prediction\preliminaries\NIKON_D3x\responses_vs_capture_settings.mat'));

% normalize raw responses by the (normalized) product of exposure time and ISO level
brightness_factor = exposures .* iso_levels;
brightness_factor = brightness_factor / brightness_factor(1);

mean_values = mean_values ./ brightness_factor;

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on; grid on; box on;

x = 1:numel(brightness_factor);

plot(x, mean_values(:, 1), 'color', RED, 'marker', 'o',...
     'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
plot(x, mean_values(:, 2), 'color', GREEN, 'marker', 'o',...
     'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
plot(x, mean_values(:, 3), 'color', BLUE, 'marker', 'o',...
     'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);

xlim([0, numel(brightness_factor) + 1]);
ylim([0, 16000]);

hax = gca;
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0:1000:16000;

iso_labels = cellfun(@(x)sprintf('ISO%d', x), num2cell(iso_levels), 'UniformOutput', false);
exp_labels = cellfun(@(x)sprintf(' 1/%g\\,s', x), num2cell(brightness_factor./exposures), 'UniformOutput', false);
xticklabels = cellfun(@(x, y)strcat(x, ', ', y), iso_labels, exp_labels, 'UniformOutput', false);

% add a asterisk marker to those responses that have been normalized
for i = 1:numel(brightness_factor)
    if brightness_factor(i) ~= 1
        xticklabels{i} = ['$^{\ast}$', xticklabels{i}];
    end
end

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 18,...
         'TickLabelInterpreter', 'latex',...
         'XTick', x, 'XTickLabel', xticklabels,...
         'XTickLabelRotation', 90,...
         'ytick', 0:4000:16000, 'ticklength', [0, 0],...
         'xminorgrid', 'off', 'yminorgrid', 'on');

ylabel('Raw Response (in 14-bit)', 'fontsize', 26, 'fontname', 'times new roman');
     

%% 
% plot camera responses (from dark frames) w.r.t. different capture 
% settings for SONY ILCE7

clearvars -except RED GREEN BLUE data_path

% load data
load(fullfile(data_path.path, 'response_prediction\preliminaries\ILCE7\responses_vs_capture_settings.mat'));

% normalize raw responses by the (normalized) product of exposure time and ISO level
brightness_factor = exposures .* iso_levels;
brightness_factor = brightness_factor / brightness_factor(1);

mean_values = mean_values ./ brightness_factor;

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on; grid on; box on;

x = 1:numel(brightness_factor);

plot(x, mean_values(:, 1), 'color', RED, 'marker', 'o',...
     'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 10);
plot(x, mean_values(:, 2), 'color', GREEN, 'marker', 'o',...
     'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 10);
plot(x, mean_values(:, 3), 'color', BLUE, 'marker', 'o',...
     'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 10);

xlim([0, numel(brightness_factor) + 1]);
ylim([0, 3600]);

hax = gca;
hax.YAxis.MinorTick = 'on';
hax.YAxis.MinorTickValues = 0:200:3600;

iso_labels = cellfun(@(x)sprintf('ISO%d', x), num2cell(iso_levels), 'UniformOutput', false);
exp_labels = cellfun(@(x)sprintf(' 1/%g\\,s', x), num2cell(brightness_factor./exposures), 'UniformOutput', false);
xticklabels = cellfun(@(x, y)strcat(x, ', ', y), iso_labels, exp_labels, 'UniformOutput', false);

% add a asterisk marker to those responses that have been normalized
for i = 1:numel(brightness_factor)
    if brightness_factor(i) ~= 1
        xticklabels{i} = ['$^{\ast}$', xticklabels{i}];
    end
end

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 18,...
         'TickLabelInterpreter', 'latex',...
         'XTick', x, 'XTickLabel', xticklabels,...
         'XTickLabelRotation', 90,...
         'ytick', 0:600:3600, 'ticklength', [0, 0],...
         'xminorgrid', 'off', 'yminorgrid', 'on');
     
ylabel('Raw Response (in 12-bit)', 'fontsize', 26, 'fontname', 'times new roman');
     