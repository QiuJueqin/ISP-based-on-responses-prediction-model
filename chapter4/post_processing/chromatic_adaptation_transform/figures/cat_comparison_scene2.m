% comparison of images with and without chromatic adaptation transformation

clear; close all; clc;

BRIGHTNESS_SCALE = 2.4;
CROP_MARGIN = 200;

data_config = parse_data_config;

% read camera parameters
params_dir = fullfile(data_config.path,...
                      'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
load(params_dir);

% read iso profile
iso_profile = load(fullfile(data_config.path,...
                            'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\gains_profile.mat'));
                        
% read color correction profile
cc_profile = load(fullfile(data_config.path,...
                           'color_correction\NIKON_D3x\cc_profile.mat'));

img_dir = fullfile(data_config.path,...
                    'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\DSC_2802.png');

img = double(imread(img_dir)) / (2^16 - 1);

raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
raw_dir = strrep(raw_dir, '.png', '.NEF');
info = getrawinfo(raw_dir);
iso = info.DigitalCamera.ISOSpeedRatings;
exposure_time = info.DigitalCamera.ExposureTime;

% estimate the luminance of the white object in the input image
luminance = luminance_estimate(img, iso, exposure_time, params, iso_profile);
% set the adapting luminance to be 20% of the luminance of the white object
LA = 0.2 * luminance;

rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
rgb = dlmread(rgb_dir);
rgb = max(min(rgb, 1), 0);

illuminant_rgb = get_illuminant_rgb(rgb);
awb_gains = illuminant_rgb(2) ./ illuminant_rgb;

% awb gains with chromatic adaptation transformation
[post_gains, cct] = catgain(awb_gains, cc_profile, 1, LA);
awb_gains_cat = awb_gains .* post_gains;

img = max(min(BRIGHTNESS_SCALE * img, 1), 0);
[height, width, ~] = size(img);
img = img(CROP_MARGIN : height - CROP_MARGIN,...
          round((width/height)*CROP_MARGIN) : width - round((width/height)*CROP_MARGIN),...
          :);

% image without chromatic adaptation transformation
img_wb = img .* reshape(awb_gains, 1, 1, 3);
img_wb = max(min(img_wb, 1), 0);
img_cc = cc(img_wb, awb_gains, cc_profile);
img_cc = lin2rgb(img_cc);
img_cc = imadjust(img_cc, [0.04, 0.96], [0, 1]);

% image with chromatic adaptation transformation
img_wb_cat = img .* reshape(awb_gains_cat, 1, 1, 3);
img_wb_cat = max(min(img_wb_cat, 1), 0);
img_cc_cat = cc(img_wb_cat, awb_gains, cc_profile);
img_cc_cat = lin2rgb(img_cc_cat);
img_cc_cat = imadjust(img_cc_cat, [0.04, 0.96], [0, 1]);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 32, 20]);
imshow(img_cc);
s = sprintf(['Without chromatic adaptation transformation (corrected to D65)\n',...
             'Ground-truth illuminant CCT: %dK'], cct);
title(s);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 32, 20]);
imshow(img_cc_cat);
title('With chromatic adaptation transformation');
