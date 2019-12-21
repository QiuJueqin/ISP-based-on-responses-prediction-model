% perform color correction for all images in Nikon D3x ColorChecker dataset

clear; close all; clc;

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x',...
                                    {'responses', 'gains', 'color'});

% read test images
dataset_dir = fullfile(data_config.path,...
                        'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\*.png');
dataset = dir(dataset_dir);

for i = 1:numel(dataset)
    img_dir = fullfile(dataset(i).folder, dataset(i).name);
    [~, img_name, ~] = fileparts(img_dir);
    
    fprintf('Processing %s (%d/%d)... ', img_name, i, numel(dataset));
    tic;
    
    img = double(imread(img_dir)) / (2^16 - 1);
    
    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    gains = iso2gains(iso, camera_config.gains);
    
    img = raw2linear(img, camera_config.responses.params, gains);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);
    rgb = raw2linear(rgb, camera_config.responses.params, gains);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    awb_gains = illuminant_rgb(2) ./ illuminant_rgb;
    
    img_wb = img .* reshape(awb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    
    img_cc = cc(img_wb, awb_gains, camera_config.color);
 	img_cc = lin2rgb(img_cc);
    
    img_save_dir = fullfile(data_config.path,...
                            'color_correction\NIKON_D3x\colorchecker_dataset_results',...
                            sprintf('%s.png', img_name));
    imwrite(img_cc, img_save_dir);
    
    t = toc;
    fprintf('done. (%.3fs elapsed)\n', t);
    
end
