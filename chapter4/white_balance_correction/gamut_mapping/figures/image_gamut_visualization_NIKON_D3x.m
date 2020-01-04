clear; close all; clc;

STD_ILLUMINANT_RGB = [0.4207, 1, 0.7713]; % only for Nikon D3x
RED = [255, 84, 84]/255;
BLUE = [0, 128, 220]/255;
LIGHT_BLUE = [177, 224, 239]/255;
PINK = [250, 230, 231]/255;
GREY = [.8, .8, .8];
NEUTRAL_REGION0 = [-0.3,  0.05;...
                    0,    0.15;...
                    0.6,  0.15;...
                    0.8,  0.05;...
                    0.8, -0.05;...
                   -0.3, -0.05;...
                   -0.3,  0.05];
               
data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x',...
                                    {'ocp', 'standard_gamut'});

img_dir = fullfile(data_config.path,...
                   'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\DSC_2790.png');
mask_dir = strrep(img_dir, '.png', '_mask.txt');

img = double(imread(img_dir)) / (2^16 - 1);
mask = dlmread(mask_dir);

rgb = img2rgb(img, mask);

rb = rgb(:, [1, 3]) ./ rgb(:, 2);

[candidate_neutral_region, gamut_of_maps, vertices_maps] = gmap(rgb,...
                                                                camera_config.ocp.ocp_params,...
                                                                camera_config.standard_gamut.std_gamut,...
                                                                STD_ILLUMINANT_RGB);

neutral_region = poly2_intersect(NEUTRAL_REGION0, candidate_neutral_region);

% plot gamut of image (2d)
gamut_visualize(rb, camera_config.standard_gamut.std_gamut, true, {'$\frac{D_r}{D_g}$', '$\frac{D_b}{D_g}$'});

% plot gamut of image (3d)
gamut_visualize(rgb);

xlim([0, 1]); ylim([0, 1]); zlim([0, 1]);

xlabel('$D_r$', 'fontsize', 28, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [0.5, -0.25, 0]);
ylabel('$D_g$', 'fontsize', 28, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [-0.25, 0.5, 0]);
zlabel('$D_b$', 'fontsize', 28, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [-0.15, 1.15, 0.5]);

set(gca, 'xtick', 0:0.2:1, 'ytick', 0:0.2:1, 'ztick', 0:0.2:1,...
         'fontsize', 20,...
         'dataaspectratio', [1, 1, 1.2]);

% plot gamut of mappings
cmap = brewermap(numel(vertices_maps), 'spectral');

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
hold on; grid on; box on;

for i = 1:numel(vertices_maps)
    vmap = vertices_maps{i};
    line(vmap(:, 1), vmap(:, 2), 'linewidth', 2, 'color', cmap(i, :));
end

hpatch = patch(gamut_of_maps(:, 1), gamut_of_maps(:, 2), LIGHT_BLUE,...
               'linewidth', 3, 'linestyle', '-.',...
               'edgecolor', BLUE);

xlim([0, 8]);
ylim([0, 4]);

legend(hpatch,...
       ' Gamut of Gamuts Mappings',...
       'fontsize', 24, 'fontname', 'times new roman', 'edgecolor', 'none');

xlabel('$M_r$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');
ylabel('$M_b$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');

set(gca, 'fontname', 'times new roman', 'fontsize', 22, 'linewidth', 1.5,...
         'xtick', -0:2:12, 'ytick', 0:1:5);

     
% plot gamut of candidate illuminants
figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 19]);
hold on; grid on; box on;

hpatch(1) = patch(candidate_neutral_region(:, 1), candidate_neutral_region(:, 2), LIGHT_BLUE,...
                  'linewidth', 3, 'linestyle', '-.',...
                  'edgecolor', BLUE, 'facealpha', .4);
legends{1} = ' Gamut of Candidate Illuminants';

hpatch(2) = patch(NEUTRAL_REGION0(:, 1), NEUTRAL_REGION0(:, 2), PINK,...
                  'linewidth', 3, 'linestyle', ':',...
                  'edgecolor', RED, 'facealpha', .6);
legends{2} = ' Candidate Neutral Region (User-Specified)';

hpatch(3) = patch(neutral_region(:, 1), neutral_region(:, 2), GREY,...
                  'linestyle', 'none');
legends{3} = ' Intersected Neutral Region';

% override the intersected region
line(candidate_neutral_region(:, 1), candidate_neutral_region(:, 2),...
     'linewidth', 3, 'linestyle', '-.',...
     'color', BLUE);
line(NEUTRAL_REGION0(:, 1), NEUTRAL_REGION0(:, 2),...
     'linewidth', 3, 'linestyle', ':',...
     'color', RED);
 
xlim([-0.8, 1.2]);
ylim([-0.6, 0.9]);

legend(hpatch, legends,...
       'fontsize', 24, 'fontname', 'times new roman', 'edgecolor', 'none');

xlabel('$X_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');
ylabel('$Y_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');

set(gca, 'fontname', 'times new roman', 'fontsize', 22, 'linewidth', 1.5,...
         'xtick', -0.8:0.4:0.8, 'ytick', -0.6:0.3:0.9);
