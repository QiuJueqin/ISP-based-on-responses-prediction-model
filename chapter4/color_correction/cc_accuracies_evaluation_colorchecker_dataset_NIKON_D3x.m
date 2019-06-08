% evaluate color reproduction accuracies for all images in Nikon D3x
% ColorChecker dataset

clear; close all; clc;

DELTA_LAMBDA = 5;
WAVELENGTHS = 400:DELTA_LAMBDA:700;
SATURATION_THRESHOLD = 0.98;

data_path = load('global_data_path.mat');

% load parameters of imaging simulation model
params_dir = fullfile(data_path.path,...
                      'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
load(params_dir);

% load spectral reflectane data of Classic ColorChecker
wavelengths = 400:10:700;
spectral_reflectance = xlsread('SpectralReflectance_Classic24_SP64.csv', 1, 'Q5:AU52') / 100;
spectral_reflectance = interp1(wavelengths, spectral_reflectance', WAVELENGTHS, 'pchip')';
spectral_reflectance = (spectral_reflectance(1:2:end, :) + spectral_reflectance(2:2:end, :)) / 2;
% calculate XYZ values
lin_srgb_ground_truth = spectra2colors(spectral_reflectance, WAVELENGTHS, 'spd', 'd65', 'output', 'srgb');

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
    
    raw_dir = strrep(img_dir, '\colorchecker_dataset\', '\colorchecker_dataset\raw\');
    raw_dir = strrep(raw_dir, '.png', '.NEF');
    info = getrawinfo(raw_dir);
    iso = info.DigitalCamera.ISOSpeedRatings;
    gains = iso2gains(iso, iso_profile);
    
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    rgb = dlmread(rgb_dir);
    rgb = max(min(rgb, 1), 0);
    rgb = raw2linear(rgb, params, gains);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    awb_gains = illuminant_rgb(2) ./ illuminant_rgb;
    
    rgb_wb = rgb .* awb_gains;
    
    % skip over-exposured image
    if max(rgb_wb(:)) > SATURATION_THRESHOLD
        continue;
    end
    
    lin_srgb_cc = cc(rgb_wb, awb_gains, cc_profile);
 	
    % find an optimal scaling factor
    srgb_ground_truth = lin2rgb(lin_srgb_ground_truth);
    lab_ground_truth = rgb2lab(srgb_ground_truth);
    
    lin_srgb_cc_scaled = @(x) x*lin_srgb_cc;
    srgb_cc_scaled = @(x) lin2rgb(lin_srgb_cc_scaled(x));
    lab_cc_scaled = @(x) rgb2lab(srgb_cc_scaled(x));
    cost_fun_ciede00 = @(x) mean(ciede00(lab_ground_truth, lab_cc_scaled(x)));
    cost_fun_ciedelab = @(x) mean(ciedelab(lab_ground_truth, lab_cc_scaled(x)));
    
    scale_ciede00 = fminbnd(cost_fun_ciede00, 0.1, 10);
    scale_ciedelab = fminbnd(cost_fun_ciedelab, 0.1, 10);
    
    errors_scaled.(img_name).ciede00 = ...
        ciede00(lab_ground_truth, rgb2lab(lin2rgb(scale_ciede00*lin_srgb_cc)));
    errors_scaled.(img_name).ciedelab = ... 
        ciedelab(lab_ground_truth, rgb2lab(lin2rgb(scale_ciedelab*lin_srgb_cc)));
    
    errors.(img_name).ciede00 = ...
        ciede00(lab_ground_truth, rgb2lab(lin2rgb(lin_srgb_cc)));
    errors.(img_name).ciedelab = ... 
        ciedelab(lab_ground_truth, rgb2lab(lin2rgb(lin_srgb_cc)));
    
    t = toc;
    fprintf('done. (%.3fs elapsed)\n', t);
    
end

save_dir = fullfile(data_path.path, 'color_correction\NIKON_D3x\colorchecker_dataset_results\cc_accuracies.mat');
save(save_dir, 'errors', 'errors_scaled');

img_names = fieldnames(errors_scaled);
avg_err_ciede00 = [];
avg_err_ciedelab = [];
for i = 1:numel(img_names)
    avg_err_ciede00 = [avg_err_ciede00; mean(errors_scaled.(img_names{i}).ciede00)];
    avg_err_ciedelab = [avg_err_ciedelab; mean(errors_scaled.(img_names{i}).ciedelab)];
end

fprintf([repmat('=', 1, 80), '\n']);

fprintf(['ciede00 color difference statistics:\n',...
         '%.2f (mean), %.2f (median), %.2f (trimean), %.2f (best 25%%), %.2f (worst 25%%)\n'],...
         mean(avg_err_ciede00), median(avg_err_ciede00), trimean(avg_err_ciede00),...
         best25(avg_err_ciede00), worst25(avg_err_ciede00));
     
fprintf(['ciedelab color difference statistics:\n',...
         '%.2f (mean), %.2f (median), %.2f (trimean), %.2f (best 25%%), %.2f (worst 25%%)\n'],...
         mean(avg_err_ciedelab), median(avg_err_ciedelab), trimean(avg_err_ciedelab),...
         best25(avg_err_ciedelab), worst25(avg_err_ciedelab));

     
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


function y = trimean(x)
assert(isvector(x));
y = (prctile(x, 25) + 2*prctile(x, 50) + prctile(x, 75)) / 4;
end


function y = best25(x)
assert(isvector(x));
x = x(x <= prctile(x, 25));
y = mean(x);
end


function y = worst25(x)
assert(isvector(x));
x = x(x >= prctile(x, 75));
y = mean(x);
end