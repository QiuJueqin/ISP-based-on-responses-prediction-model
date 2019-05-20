clear; close all; clc;

DARKNESS_THRESHOLD = 0.1;
XLIM = [-0.6, 1.2];
YLIM = [-0.4, 0.6];
GRID_SIZE = 64;
STD_ILLUMINANT_RGB = [0.4207, 1, 0.7713]; % only for Nikon D3x
NEUTRAL_REGION0 = [-0.3,  0.05;...
                    0,    0.15;...
                    0.6,  0.15;...
                    0.8,  0.05;...
                    0.8, -0.05;...
                   -0.3, -0.05;...
                   -0.3,  0.05];
               
data_path = load('global_data_path.mat');

% load ocp parameters
ocp_params_dir = fullfile(data_path.path,...
                          'white_balance_correction\neutral_point_statistics\NIKON_D3x\ocp_params.mat');
load(ocp_params_dir);

% load standard gamut
std_gamut_dir = fullfile(data_path.path,...
                         'white_balance_correction\gamut_mapping\NIKON_D3x\std_gamut.mat');
load(std_gamut_dir);


img_dir = fullfile(data_path.path,...
                   'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\DSC_2790.png');
mask_dir = strrep(img_dir, '.png', '_mask.txt');

img = double(imread(img_dir)) / (2^16 - 1);
mask = dlmread(mask_dir);

rgb = img2rgb(img, mask);

[candidate_neutral_region, gamut_of_maps, vertices_maps] = gmap(rgb, ocp_params, std_gamut, STD_ILLUMINANT_RGB);

neutral_region = poly2_intersect(NEUTRAL_REGION0, candidate_neutral_region);

[~, whist1] = npstat(rgb, ocp_params, NEUTRAL_REGION0, XLIM, YLIM, GRID_SIZE);
hist_visualize(whist1, NEUTRAL_REGION0);
set(gca, 'ztick', 0:2E2:1E3);

[~, whist2] = npstat(rgb, ocp_params, neutral_region, XLIM, YLIM, GRID_SIZE);
hist_visualize(whist2, neutral_region);
set(gca, 'ztick', 0:2E2:1E3);


