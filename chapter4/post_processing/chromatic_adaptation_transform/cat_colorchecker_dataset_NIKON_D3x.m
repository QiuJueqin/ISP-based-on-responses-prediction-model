% comparison of images with and without chromatic adaptation transformation

clear; close all; clc;

img_names = {'DSC_2445', 'DSC_2328', 'DSC_2450',...
             'DSC_2327', 'DSC_2326', 'DSC_2441'};

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x', {'responses', 'gains', 'color'});

imgs_dir = fullfile(data_config.path,...
                    'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset');

for i = 1:numel(img_names)
    img_dir = fullfile(imgs_dir, [img_names{i}, '.png']);
    
    img = double(imread(img_dir)) / (2^16 - 1);
    
    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    exposure_time = info.DigitalCamera.ExposureTime;
    
    % estimate the luminance of the white object in the input image
    luminance = luminance_estimate(img, iso, exposure_time,...
                                   camera_config.responses.params,...
                                   camera_config.gains);
    % set the adapting luminance to be 20% of the luminance of the white object
    LA = 0.2 * luminance;
    fprintf('adapting luminance for %s is %.1f cd/m^2.\n',...
            img_names{i}, LA);

    gains = iso2gains(iso, camera_config.gains);
    img = raw2linear(img, camera_config.responses.params, gains);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);
    rgb = raw2linear(rgb, camera_config.responses.params, gains);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    wb_gains = illuminant_rgb(2) ./ illuminant_rgb;
    
    % awb gains with chromatic adaptation transformation
    [post_gains, cct] = catgain(wb_gains, camera_config.color, 1, LA);
    wb_gains_cat = wb_gains .* post_gains;
    
    % image without chromatic adaptation transformation
    img_wb = img .* reshape(wb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    img_cc = cc(img_wb, wb_gains, camera_config.color);
 	img_cc = lin2rgb(img_cc);
    
    % image with chromatic adaptation transformation
    img_wb_cat = img .* reshape(wb_gains_cat, 1, 1, 3);
    img_wb_cat = max(min(img_wb_cat, 1), 0);
    img_cc_cat = cc(img_wb_cat, wb_gains, camera_config.color);
 	img_cc_cat = lin2rgb(img_cc_cat);
    
    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 32, 20]);
    subplot(1, 2, 1); imshow(img_cc);
    s = sprintf(['Without chromatic adaptation transformation (corrected to D65)\n',...
                 'Ground-truth illuminant CCT: %dK'], cct);
    title(s);
    subplot(1, 2, 2); imshow(img_cc_cat);
    title('With chromatic adaptation transformation');
end
