% plot the response falloff in a non-uniform image

clear; close all; clc;

RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;
HEIGHT = 1560;
WIDTH = 2104;
KNOTS = [0, .15, .3, .5, .7, .85, 1];
ORDER = 3;

config = parse_data_config;

% load data
load(fullfile(config.data_path, 'nonuniformity_correction\OV8858\nonuniformity_profile.mat'));

for i = 1:numel(nonuniformity_profile.params)
    coefs = nonuniformity_profile.params(i).coefs;

    knots = augknt(KNOTS, ORDER);

    x = linspace(0, 1, WIDTH);
    y = linspace(0, 1, HEIGHT);

    falloff = zeros(HEIGHT, WIDTH, 3);
    for k = 1:3
        falloff_ = 1 ./ (spcol(knots, ORDER, y) * coefs(:, :, k) * spcol(knots, ORDER, x)');
        falloff(:, :, k) = falloff_ / max(falloff_(:));
    end

    section_roi = falloff(HEIGHT/2+(-5:5), :, :);
    section_line = squeeze(mean(section_roi, 1))';

    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
    hax = axes('units', 'normalized', 'position', [.1 .15 .8 .7]);
    hold on; box off; axis off;
    xlim([-1, 1]);
    ylim([0, 1.1]);
    pos = get(hax, 'position');
    annotation('arrow',...
               [pos(1)+pos(3)/2; pos(1)+pos(3)/2],...
               [pos(2); pos(2)+pos(4)],...
               'headstyle', 'vback1', 'linewidth', 2);
    annotation('doublearrow',...
               [pos(1); pos(1)+pos(3)],...
               [pos(2); pos(2)],...
               'headstyle','vback1', 'head2style', 'vback1', 'linewidth', 2);

    t = linspace(-1, 1, WIDTH);

    plot(t, section_line(1, :), 'color', RED, 'linewidth', 3);
    plot(t, section_line(2, :), 'color', GREEN, 'linewidth', 3);
    plot(t, section_line(3, :), 'color', BLUE, 'linewidth', 3);

    text(1, -0.1, 'Distance',...
         'fontname', 'times new roman', 'fontsize', 30, 'horizontalalignment', 'center');
    text(-1, -0.1, 'Distance',...
         'fontname', 'times new roman', 'fontsize', 30, 'horizontalalignment', 'center');
    text(0, -0.1, 'Optical Center',...
         'fontname', 'times new roman', 'fontsize', 30, 'horizontalalignment', 'center');
    text(0, 1.18, 'Normalized Response',...
         'fontname', 'times new roman', 'fontsize', 30, 'horizontalalignment', 'center');
end