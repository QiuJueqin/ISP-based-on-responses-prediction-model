% visualize parameters of spline surfaces for OmniVision OV8858

clear; close all; clc;

CMAP = [brewermap(32, 'Reds');...
        brewermap(32, 'Greens');...
        brewermap(32, 'Blues')];

data_config = parse_data_config;

% load profile
load(fullfile(data_config.path, 'nonuniformity_correction\OV8858\nonuniformity_profile.mat'));

for i = 1:numel(nonuniformity_profile.params)
    coefs = nonuniformity_profile.params(i).coefs;

    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 18, 16]);
    grid on;
    colormap(CMAP);
    
    max_ = 0;
    for k = 1:3
        tmp = coefs(:, :, k);
        hs = surf(tmp);
        
        hold on;
        
        cdata_ = get(hs, 'cdata');
        cdata_ = cdata_ / (max(cdata_(:)) - min(cdata_(:)));
        
        set(hs, 'cdata', cdata_ + max_);
        max_ = max_ + max(cdata_(:));
    end

    xlim([1, 8]);
    ylim([1, 8]);
    zlim([0, 10]);
    
    set(gca, 'fontname', 'times new roman', 'fontsize', 30,...
             'linewidth', 1,...
             'xtick', 1:8, 'xticklabel', [],...
             'ytick', 1:8, 'yticklabel', [],...
             'ztick', 0:2:10,...
             'ticklength', [0, 0.02],...
             'dataaspectratio', [1, 1, 1.5]);
    
	xlabel('$x$', 'fontname', 'times new roman', 'fontsize', 30,...
           'interpreter', 'latex', 'position', [4.8, 0.8, 0.06]);
    ylabel('$y$', 'fontname', 'times new roman', 'fontsize', 30,...
           'interpreter', 'latex', 'position', [0.66, 4.84, 0.11]);
end
