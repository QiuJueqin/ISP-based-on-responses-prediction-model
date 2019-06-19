% comparison of images with and without chromatic adaptation transformation

clear; close all; clc;

img_names = {'DSC_2445', 'DSC_2328', 'DSC_2450',...
             'DSC_2327', 'DSC_2326', 'DSC_2441'};

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

imgs_dir = fullfile(config.data_path,...
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
    luminance = luminance_estimate(img, iso, exposure_time, params, iso_profile);
    % set the adapting luminance to be 20% of the luminance of the white object
    LA = 0.2 * luminance;
    fprintf('adapting luminance for %s is %.1f cd/m^2.\n',...
            img_names{i}, LA);

    gains = iso2gains(iso, iso_profile);
    img = raw2linear(img, params, gains);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);
    rgb = raw2linear(rgb, params, gains);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    awb_gains = illuminant_rgb(2) ./ illuminant_rgb;
    
    % awb gains with chromatic adaptation transformation
    [post_gains, cct] = getpostgains(awb_gains, cc_profile, 1, LA);
    awb_gains_cat = awb_gains .* post_gains;
    
    % image without chromatic adaptation transformation
    img_wb = img .* reshape(awb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    img_cc = cc(img_wb, awb_gains, cc_profile);
 	img_cc = lin2rgb(img_cc);
    
    % image with chromatic adaptation transformation
    img_wb_cat = img .* reshape(awb_gains_cat, 1, 1, 3);
    img_wb_cat = max(min(img_wb_cat, 1), 0);
    img_cc_cat = cc(img_wb_cat, awb_gains, cc_profile);
 	img_cc_cat = lin2rgb(img_cc_cat);
    
    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 32, 20]);
    subplot(1, 2, 1); imshow(img_cc);
    s = sprintf(['Without chromatic adaptation transformation (corrected to D65)\n',...
                 'Ground-truth illuminant CCT: %dK'], cct);
    title(s);
    subplot(1, 2, 2); imshow(img_cc_cat);
    title('With chromatic adaptation transformation');
end


% ==============================================

function illuminant_rgb = get_illuminant_rgb(rgb)
DARKNESS_THRESHOLD = 0.05;
SATURATION_THRESHOLD = 0.9;

assert(isequal(size(rgb), [24, 3]));

idx = 20;
illuminant_rgb = rgb(idx, :);

if min(illuminant_rgb) < DARKNESS_THRESHOLD
    illuminant_rgb = rgb(19, :);
end

while max(illuminant_rgb) > SATURATION_THRESHOLD
    idx = idx + 1;
    illuminant_rgb = rgb(idx, :);
end

if idx >= 23
    warning('image is oversaturated.');
end

illuminant_rgb = illuminant_rgb / illuminant_rgb(2);

end
