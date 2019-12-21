clear; close all; clc;

data_config = parse_data_config;
load(fullfile(data_config.path,...
              'color_correction\NIKON_D3x\color_correction_calibration_data.mat'));

for i = 1:numel(unknown_illuminant_names)
    iname = unknown_illuminant_names{i};
    rgb = scale.(iname) * camera_rgb_val.(iname);
    rgb_wb = scale.(iname) * camera_rgb_wb_val.(iname);
    rgb_cc = xyz2rgb(predicted_responses_val.(iname));
    
    rgb = colors2checker(rgb .^ (1/2.2), 'show', false);
    rgb_wb = colors2checker(rgb_wb .^ (1/2.2), 'show', false);
    rgb_cc = colors2checker(rgb_cc, 'show', false);
    
    rgb_dir = fullfile(data_config.path,...
                       sprintf('color_correction\\NIKON_D3x\\rgb_%s.png', iname));
    rgb_wb_dir = fullfile(data_config.path,...
                          sprintf('color_correction\\NIKON_D3x\\rgb_wb_%s.png', iname));
	rgb_cc_dir = fullfile(data_config.path,...
                          sprintf('color_correction\\NIKON_D3x\\rgb_cc_%s.png', iname));
    imwrite(rgb, rgb_dir);
    imwrite(rgb_wb, rgb_wb_dir);
    imwrite(rgb_cc, rgb_cc_dir);
    
    color_diff(canonical_xyz_val, predicted_responses_val.(iname));
    
    color_diff_dir = fullfile(data_config.path,...
                              sprintf('color_correction\\NIKON_D3x\\color_diff_%s.png', iname));
    export_fig(color_diff_dir, '-r150');
    
    close all;
end
