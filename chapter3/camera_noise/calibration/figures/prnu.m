%% show pixel response non-uniformity map for NIKON D3x

clear; close all; clc;

data_config = parse_data_config;

load(fullfile(data_config.path, 'noise_calibration\NIKON_D3x\EXP8_ISO100_F4_55mm\noise_profile.mat'));

cmap = flipud(brewermap(64, 'RdBu'));

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 25, 15]);
hax = axes(hfig, 'position', [.025 .05 .85 .9]);

% cut off the edges
imshow(noise_profile.K_estimate(11:end-10, 11:end-10, 2), [0.99, 1.01], 'parent', hax);
colormap(cmap);
colorbar('ticks', [0.99:0.005:1.01], 'linewidth', 2, 'position', [.875 .05 .025 .9]);
set(gca, 'fontname', 'Times New Roman', 'fontsize', 22);


%% show pixel response non-uniformity map for SONY ILCE7

clear; clc;

data_config = parse_data_config;

load(fullfile(data_config.path, 'noise_calibration\ILCE7\EXP8_ISO100_F4_55mm\noise_profile.mat'));

cmap = flipud(brewermap(64, 'RdBu'));

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 25, 15]);
hax = axes(hfig, 'position', [.025 .05 .85 .9]);

% cut off the edges
imshow(noise_profile.K_estimate(11:end-10, 11:end-10, 2), [0.99, 1.01], 'parent', hax);
colormap(cmap);
colorbar('ticks', [0.99:0.005:1.01], 'linewidth', 2, 'position', [.875 .05 .025 .9]);
set(gca, 'fontname', 'Times New Roman', 'fontsize', 22);
