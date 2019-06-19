clear; close all; clc;

DARKNESS_THRESHOLD = 0.1;
XLIM = [-0.6, 1.2];
YLIM = [-0.4, 0.6];
RED = [255, 84, 84]/255;
GRID_SIZE = 64;
NEUTRAL_REGION = [-0.3,  0.05;...
                   0,    0.15;...
                   0.6,  0.15;...
                   0.8,  0.05;...
                   0.8, -0.05;...
                  -0.3, -0.05;...
                  -0.3,  0.05];

config = parse_data_config;

img_dir = fullfile(config.data_path,...
                   'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\DSC_2790.png');
mask_dir = strrep(img_dir, '.png', '_mask.txt');
    
% load ocp parameters
ocp_params_dir = fullfile(config.data_path,...
                          'white_balance_correction\neutral_point_statistics\NIKON_D3x\ocp_params.mat');
load(ocp_params_dir);

img = double(imread(img_dir)) / (2^16 - 1);
mask = dlmread(mask_dir);

rgb = img2rgb(img, mask);

[gains, whist, whist_moved, hist_moved, whist0, hist0] =...
    npstat(rgb, ocp_params, NEUTRAL_REGION, XLIM, YLIM, GRID_SIZE);

% hist0
hist_visualize(hist0);
set(gca, 'ztick', 0:1E4:4E4);

% whist0
hist_visualize(whist0);
set(gca, 'ztick', 0:2E2:1E3);

% whist0 with neutral region boundary
hist_visualize(whist0, NEUTRAL_REGION);
set(gca, 'ztick', 0:2E2:1E3);

% whist
hist_visualize(whist);
set(gca, 'ztick', 0:2E2:1E3);
