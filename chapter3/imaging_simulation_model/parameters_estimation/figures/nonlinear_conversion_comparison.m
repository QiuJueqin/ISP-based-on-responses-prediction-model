%% compare raw images before and after non-linearity conversion

clear; close all; clc;

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x', {'responses', 'gains'});

sample_raw_dir = fullfile(data_config.path, 'noise_calibration\NIKON_D3x\dsg_sample.NEF');

bits = 14;
[raw, info] = matrawread(sample_raw_dir, 'inbit', bits, 'outbit', 'same');
iso = info.DigitalCamera.ISOSpeedRatings;

% noise correction
load(fullfile(data_config.path, 'noise_calibration\NIKON_D3x\EXP8_ISO100_F4_55mm\noise_profile.mat'));
raw = noise_corr(double(raw), noise_profile);

% non-linearity conversion
gains = iso2gains(iso, camera_config.gains);

img = raw / (2^bits - 1);
img = max(min(img, 1), 0);

img_linear = raw2linear(img, camera_config.responses.params, gains);

figure; imshow(img);
figure; imshow(img_linear);

diff = abs(img - img_linear)./img_linear;

cmap = brewermap(64, 'OrRd');

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 25, 15]);
hax = axes(hfig, 'position', [.025 .05 .85 .9]);
imshow(diff(11:end-10, 11:end-10, 2), [0 0.25], 'parent', hax);
colormap(cmap);
colorbar('ticks', 0:0.05:0.25,...
         'ticklabels', cellfun(@(x)[num2str(x),'%'], num2cell(0:5:25), 'UniformOutput', false),...
         'linewidth', 2, 'position', [.875 .05 .025 .9]);
set(gca, 'fontname', 'Times New Roman', 'fontsize', 26);
