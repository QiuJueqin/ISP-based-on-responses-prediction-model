clear; close all; clc;

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x',...
                                    {'responses', 'gains', 'color'});

% sample images
image_names = {'DSC_2368', ...
               'DSC_2838', ...
               'DSC_2830', ...
               'DSC_2349', ...
               'DSC_2432'};
scales = [3.2, 2.5, 3, 2.2, 2];

for i = 1:numel(image_names)
    img_name = image_names{i};
    img_dir = fullfile(data_config.path, 'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset', [img_name, '.png']);
    
    img = double(imread(img_dir)) / (2^16 - 1);
    
    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    gains = iso2gains(iso, camera_config.gains);
    
    img = scales(i) * raw2linear(img, camera_config.responses.params, gains);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);
    rgb = raw2linear(rgb, camera_config.responses.params, gains);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    
    awb_gains = illuminant_rgb(2) ./ illuminant_rgb;
    
    img_wb = img .* reshape(awb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    
    img_cc = cc(img_wb, awb_gains, camera_config.color);
    
    img_wb = lin2rgb(imresize(img_wb, 1/4));
    img_cc = lin2rgb(imresize(img_cc, 1/4));
    
    img_wb_save_dir = fullfile(data_config.path,...
                               'color_correction\NIKON_D3x\',...
                               sprintf('%s_wb.tiff', img_name));
    imwrite(img_wb, img_wb_save_dir);
    
    img_cc_save_dir = fullfile(data_config.path,...
                               'color_correction\NIKON_D3x\',...
                               sprintf('%s_cc.tiff', img_name));
    imwrite(img_cc, img_cc_save_dir);
    
end

