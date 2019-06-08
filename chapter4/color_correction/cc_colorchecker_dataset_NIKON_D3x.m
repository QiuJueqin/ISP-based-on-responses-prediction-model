% perform color correction for all images in Nikon D3x ColorChecker dataset

clear; close all; clc;

data_path = load('global_data_path.mat');

% read camera parameters
params_dir = fullfile(data_path.path,...
                      'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
load(params_dir);

% read iso profile
iso_profile = load(fullfile(data_path.path,...
                            'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\gains_profile.mat'));
                        
% read color correction profile
cc_profile = load(fullfile(data_path.path,...
                           'color_correction\NIKON_D3x\cc_profile.mat'));

% read test images
database_dir = fullfile(data_path.path,...
                        'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\*.png');
database = dir(database_dir);

for i = 1:numel(database)
    img_dir = fullfile(database(i).folder, database(i).name);
    [~, img_name, ~] = fileparts(img_dir);
    
    fprintf('Processing %s (%d/%d)... ', img_name, i, numel(database));
    tic;
    
    img = double(imread(img_dir)) / (2^16 - 1);
    
    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    gains = iso2gains(iso, iso_profile);
    
    img = raw2linear(img, params, gains);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);
    rgb = raw2linear(rgb, params, gains);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    awb_gains = illuminant_rgb(2) ./ illuminant_rgb;
    
    img_wb = img .* reshape(awb_gains, 1, 1, 3);
    img_wb = max(min(img_wb, 1), 0);
    
    img_cc = cc(img_wb, awb_gains, cc_profile);
 	img_cc = lin2rgb(img_cc);
    
    img_save_dir = fullfile(data_path.path,...
                            'color_correction\NIKON_D3x\colorchecker_dataset_results',...
                            sprintf('%s.png', img_name));
    imwrite(img_cc, img_save_dir);
    
    t = toc;
    fprintf('done. (%.3fs elapsed)\n', t);
    
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
