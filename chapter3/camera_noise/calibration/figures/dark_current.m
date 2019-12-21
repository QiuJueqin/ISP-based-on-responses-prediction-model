%% show dark current map for NIKON D3x

clear; close all; clc;

data_config = parse_data_config;

load(fullfile(data_config.path, 'noise_calibration\NIKON_D3x\EXP8_ISO100_F4_55mm\noise_profile.mat'));

cmap = brewermap(64, 'OrRd');

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 15]);
hax = axes(hfig, 'position', [.025 .05 .85 .9]);

% cut off the edges
imshow(noise_profile.mu_dark_estimate(11:end-10, 11:end-10, 2), [0, 6], 'parent', hax);
colormap(cmap);
colorbar('ticks', 0:6,...
         'ticklabels', cellfun(@(x)[num2str(x),'.0'], num2cell(0:6), 'UniformOutput', false),...
         'linewidth', 2, 'position', [.9 .05 .025 .9]);
set(gca, 'fontname', 'Times New Roman', 'fontsize', 26);


%% show dark current map for SONY ILCE7

clear; clc;

data_config = parse_data_config;

load(fullfile(data_config.path, 'noise_calibration\ILCE7\EXP8_ISO100_F4_55mm\noise_profile.mat'));

cmap = brewermap(64, 'OrRd');

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 25, 15]);
hax = axes(hfig, 'position', [.025 .05 .85 .9]);

% cut off the edges
imshow(noise_profile.mu_dark_estimate(11:end-10, 11:end-10, 2), [128, 128.6], 'parent', hax);
colormap(cmap);
colorbar('linewidth', 2, 'position', [.875 .05 .025 .9]);
set(gca, 'fontname', 'Times New Roman', 'fontsize', 26);
