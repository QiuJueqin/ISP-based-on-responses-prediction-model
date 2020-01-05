% comparison of images with and without chromatic adaptation transformation

clear; close all; clc;

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x', {'responses', 'gains', 'color'});

img_names = {'DSC_2312.png', 'DSC_2838.png', 'DSC_2388.png', 'DSC_2815.png',...
             'DSC_2855.png', 'DSC_2785.png', 'DSC_2811.png', 'DSC_2835.png'};

for i = 1:numel(img_names)
    img_dir = fullfile(data_config.path,...
                       'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset',...
                       img_names{i});

    img = double(imread(img_dir)) / (2^16 - 1);

    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    exposure_time = info.DigitalCamera.ExposureTime;

    % estimate the luminance of the white object in the input image
    luminance = luminance_estimate(img, iso, exposure_time, camera_config.responses.params, camera_config.gains);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);

    illuminant_rgb = get_illuminant_rgb(rgb);
    wb_gains = illuminant_rgb(2) ./ illuminant_rgb;

    % image without chromatic adaptation transformation
    img_wb = img .* reshape(wb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    img_cc = cc(img_wb, wb_gains, camera_config.color);
    img_cc = lin2rgb(img_cc);
    img_cc = imadjust(img_cc, [0.04, 0.96], [0, 1]);
    
    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 32, 20]);
    imshow(img_cc);
    title(sprintf('estimated luminance: %.2f cd/m^2', luminance));
end

