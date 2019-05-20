% compare images before & after non-uniformity correction for OmniVision
% OV8858

clear; close all; clc;

CMAP = brewermap(64, 'Reds');
CMAP = flipud(CMAP(1:42, :));
LINECOLOR = [.4, .4, .4];

data_path = load('global_data_path.mat');

profile = load(fullfile(data_path.path, 'nonuniformity_correction\OV8858\nonuniformity_profile.mat'));

contents = dir(fullfile(data_path.path, 'nonuniformity_correction\OV8858'));
for i = 3:numel(contents)
    if contents(i).isdir
        contents_ = dir(fullfile(contents(i).folder, [contents(i).name, '\*.pgm']));
        pgm_dir = fullfile(contents_.folder, contents_.name);
        img = pgmread(pgm_dir);
        img = imresize(img, 1/2);
        
        [height, width, ~] = size(img);
        roi = img(round(0.49*height) : round(0.51*height),...
                  round(0.49*width) : round(0.51*width),...
                  :);
        roi_mean = mean(roi, [1, 2]);
        gains = roi_mean(2) ./ squeeze(roi_mean)';
        
        img_corr = nonuniformity_corr(img, gains, profile.nonuniformity_profile);

        % smoothen
        img = imgaussfilt3(img(:, :, 2), 5); % only green channel
        img_corr = imgaussfilt3(img_corr(:, :, 2), 5); % only green channel
        
        img = img / roi_mean(2);
        img_corr = img_corr / roi_mean(2);
        
        % before non-uniformity correction
        figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
        [ct, hcont] = contourf(img, 0.1:0.1:1, '--',...
                               'showtext', 'on', 'labelspacing', 128);
        hcont.LineColor = LINECOLOR;
        hcont.LineWidth = 1;
        clabel(ct, hcont, 'fontname', 'times new roman', 'fontsize', 18);
        caxis([0, 1]);
        colormap(CMAP);
        colorbar('ticks', 0:0.2:1,...
                 'fontname', 'times new roman', 'fontsize', 18,...
                 'linewidth', 1.5);
        axis off;
        
        % after non-uniformity correction
        figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
        [ct, hcont] = contourf(img_corr, 0.95:0.01:1, '--',...
                               'showtext', 'on', 'labelspacing', 80);
        hcont.LineColor = LINECOLOR;
        hcont.LineWidth = 1;
        clabel(ct, hcont, 'fontname', 'times new roman', 'fontsize', 15);
        caxis([0.95, 1]);
        colormap(CMAP);
        colorbar('ticks', 0.95:0.01:1,...
                 'fontname', 'times new roman', 'fontsize', 18,...
                 'linewidth', 1.5);
        axis off;
    end
end

