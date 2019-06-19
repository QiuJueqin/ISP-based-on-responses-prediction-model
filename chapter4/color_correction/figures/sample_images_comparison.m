clear; close all; clc;

config = parse_data_config;

% read camera parameters
load(fullfile(config.data_path,...
              'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat'));

% read iso profile
iso_profile = load(fullfile(config.data_path,...
                            'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\gains_profile.mat'));
                        
% read color correction profile
cc_profile = load(fullfile(config.data_path,...
                           'color_correction\NIKON_D3x\cc_profile.mat'));

% sample images
image_names = {'DSC_2368', ...
               'DSC_2838', ...
               'DSC_2830', ...
               'DSC_2349', ...
               'DSC_2432'};
scales = [3.2, 2.5, 3, 2.2, 2];

for i = 1:numel(image_names)
    img_name = image_names{i};
    img_dir = fullfile(config.data_path, 'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset', [img_name, '.png']);
    
    img = double(imread(img_dir)) / (2^16 - 1);
    
    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    gains = iso2gains(iso, iso_profile);
    
    img = scales(i) * raw2linear(img, params, gains);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);
    rgb = raw2linear(rgb, params, gains);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    
    awb_gains = illuminant_rgb(2) ./ illuminant_rgb;
    
    img_wb = img .* reshape(awb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    
    img_cc = cc(img_wb, awb_gains, cc_profile);
    
    img_wb = lin2rgb(imresize(img_wb, 1/4));
    img_cc = lin2rgb(imresize(img_cc, 1/4));
    
    img_wb_save_dir = fullfile(config.data_path,...
                            'color_correction\NIKON_D3x\',...
                            sprintf('%s_wb.tiff', img_name));
    imwrite(img_wb, img_wb_save_dir);
    
    img_cc_save_dir = fullfile(config.data_path,...
                            'color_correction\NIKON_D3x\',...
                            sprintf('%s_cc.tiff', img_name));
    imwrite(img_cc, img_cc_save_dir);
    
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
