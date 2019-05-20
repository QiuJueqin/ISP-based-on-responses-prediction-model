%% compare raw images before and after noise correction

clear; close all; clc;

data_path = load('global_data_path.mat');

sample_raw_dir = fullfile(data_path.path, 'noise_calibration\NIKON_D3x\dsg_sample.NEF');

bits = 14;
raw = double(matrawread(sample_raw_dir, 'inbit', bits, 'outbit', 'same'));

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 25, 15]);
hax = axes(hfig, 'position', [.025 .05 .85 .9]);
imshow(raw(11:end-10, 11:end-10, :)/(2^bits-1), 'parent', hax);

% load noise correction profile
load(fullfile(data_path.path, 'noise_calibration\NIKON_D3x\EXP8_ISO100_F4_55mm\noise_profile.mat'));
raw_corr = noise_corr(raw, noise_profile);

diff = abs(raw - raw_corr)./raw_corr;

cmap = brewermap(64, 'OrRd');

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 25, 15]);
hax = axes(hfig, 'position', [.025 .05 .85 .9]);
imshow(diff(11:end-10, 11:end-10, 2), [0 0.01], 'parent', hax);
colormap(cmap);
colorbar('ticks', 0:0.002:0.01,...
         'ticklabels', cellfun(@(x)[num2str(x),'%'], num2cell(0:0.2:1), 'UniformOutput', false),...
         'linewidth', 2, 'position', [.875 .05 .025 .9]);
set(gca, 'fontname', 'Times New Roman', 'fontsize', 26);
