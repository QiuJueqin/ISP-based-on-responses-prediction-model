clear; close all; clc;

STD_ILLUMINANT_RGB = [0.4207, 1, 0.7713]; % only for Nikon D3x
DARKNESS_THRESHOLD = 0.1;
XLIM = [-0.6, 1.2];
YLIM = [-0.4, 0.6];
RED = [255, 84, 84]/255;
BLUE = [0, 128, 220]/255;
LIGHT_BLUE = [177, 224, 239]/255;
PINK = [250, 230, 231]/255;
GREY = [.8, .8, .8];
GRID_SIZE = 64;
NEUTRAL_REGION = [-0.3,  0.05;...
                   0,    0.15;...
                   0.6,  0.15;...
                   0.8,  0.05;...
                   0.8, -0.05;...
                  -0.3, -0.05;...
                  -0.3,  0.05];

data_path = load('global_data_path.mat');

names = {'DSC_2351.png', 'DSC_2428.png', 'DSC_2396.png'};
for i = 1:3
    img_dir = fullfile(data_path.path,...
                       'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset',...
                       names{i});
    mask_dir = strrep(img_dir, '.png', '_mask.txt');

    % load ocp parameters
    ocp_params_dir = fullfile(data_path.path,...
                              'white_balance_correction\neutral_point_statistics\NIKON_D3x\ocp_params.mat');
    load(ocp_params_dir);

    % load standard gamut
    std_gamut_dir = fullfile(data_path.path,...
                             'white_balance_correction\gamut_mapping\NIKON_D3x\std_gamut.mat');
    load(std_gamut_dir);

    img = 2 * double(imread(img_dir)) / (2^16 - 1);
    mask = dlmread(mask_dir);

    rgb = img2rgb(img, mask);

    [~, whist, whist_moved, hist_moved, whist0, ~] =...
        npstat(rgb, ocp_params, NEUTRAL_REGION, XLIM, YLIM, GRID_SIZE);

    % whist0
    hist_visualize(whist0);
    set(gca, 'ztick', 0:5E2:2E3);

    % whist
    hist_visualize(whist, NEUTRAL_REGION);
    set(gca, 'ztick', 0:2E2:2E3);

    [candidate_neutral_region, ~, ~] = gmap(rgb, ocp_params, std_gamut, STD_ILLUMINANT_RGB);
    neutral_region = poly2_intersect(NEUTRAL_REGION, candidate_neutral_region);

    [gains, whist, ~, ~, ~, ~] =...
        npstat(rgb, ocp_params, neutral_region, XLIM, YLIM, GRID_SIZE);

    % whist
    hist_visualize(whist, neutral_region);
    set(gca, 'ztick', 0:2E2:2E3);

    % gamut
    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 19]);
    hold on; grid on; box on;

    hpatch(1) = patch(candidate_neutral_region(:, 1), candidate_neutral_region(:, 2), LIGHT_BLUE,...
                      'linewidth', 3, 'linestyle', '-.',...
                      'edgecolor', BLUE, 'facealpha', .4);
    legends{1} = ' Gamut of Candidate Illuminants';

    hpatch(2) = patch(NEUTRAL_REGION(:, 1), NEUTRAL_REGION(:, 2), PINK,...
                      'linewidth', 3, 'linestyle', ':',...
                      'edgecolor', RED, 'facealpha', .6);
    legends{2} = ' Candidate Neutral Region';

    hpatch(3) = patch(neutral_region(:, 1), neutral_region(:, 2), GREY,...
                      'linestyle', 'none');
    legends{3} = ' Intersected Neutral Region';

    % override the intersected region
    line(candidate_neutral_region(:, 1), candidate_neutral_region(:, 2),...
         'linewidth', 3, 'linestyle', '-.',...
         'color', BLUE);
    line(NEUTRAL_REGION(:, 1), NEUTRAL_REGION(:, 2),...
         'linewidth', 3, 'linestyle', ':',...
         'color', RED);

    xlim([-0.8, 1.2]);
    ylim([-0.6, 0.9]);

    legend(hpatch, legends,...
           'fontsize', 24, 'fontname', 'times new roman', 'edgecolor', 'k');

    xlabel('$X_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
           'interpreter', 'latex');
    ylabel('$Y_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
           'interpreter', 'latex');

    set(gca, 'fontname', 'times new roman', 'fontsize', 22, 'linewidth', 1.5,...
             'xtick', -0.8:0.4:0.8, 'ytick', -0.6:0.3:0.9);
end