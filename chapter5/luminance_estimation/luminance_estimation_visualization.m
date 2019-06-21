% comparison of images with and without chromatic adaptation transformation

clear; close all; clc;

config = parse_data_config;

% read camera parameters
params_dir = fullfile(config.data_path,...
                      'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
load(params_dir);

% read iso profile
iso_profile = load(fullfile(config.data_path,...
                            'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\gains_profile.mat'));
                        
% read color correction profile
cc_profile = load(fullfile(config.data_path,...
                           'color_correction\NIKON_D3x\cc_profile.mat'));

img_names = {'DSC_2312.png', 'DSC_2838.png', 'DSC_2388.png', 'DSC_2815.png',...
             'DSC_2855.png', 'DSC_2785.png', 'DSC_2811.png', 'DSC_2835.png'};

for i = 1:numel(img_names)
    img_dir = fullfile(config.data_path,...
                       'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset',...
                       img_names{i});

    img = double(imread(img_dir)) / (2^16 - 1);

    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    exposure_time = info.DigitalCamera.ExposureTime;

    % estimate the luminance of the white object in the input image
    luminance = luminance_estimate(img, iso, exposure_time, params, iso_profile);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);

    illuminant_rgb = get_illuminant_rgb(rgb);
    awb_gains = illuminant_rgb(2) ./ illuminant_rgb;

    % image without chromatic adaptation transformation
    img_wb = img .* reshape(awb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    img_cc = cc(img_wb, awb_gains, cc_profile);
    img_cc = lin2rgb(img_cc);
    img_cc = imadjust(img_cc, [0.04, 0.96], [0, 1]);
    
    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 32, 20]);
    imshow(img_cc);
    title(sprintf('estimated luminance: %.2f cd/m^2', luminance));
end

