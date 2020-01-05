clear; close all; clc;

DELTA_LAMBDA = 5;
WAVELENGTHS = 400:DELTA_LAMBDA:700;
ISO = 100;
T = 0.01; % 10ms

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x', {'responses', 'gains'});
gains = iso2gains(ISO, camera_config.gains);

% load spectral reflectane data of Classic ColorChecker
spectral_reflectance = xlsread('SpectralReflectance_Classic24_SP64.csv', 1, 'Q5:AU52') / 100;
wavelengths = 400:10:700;
spectral_reflectance = interp1(wavelengths, spectral_reflectance', WAVELENGTHS, 'pchip')';
spectral_reflectance = (spectral_reflectance(1:2:end, :) + spectral_reflectance(2:2:end, :)) / 2;

% calculate linear sRGB values
lin_srgb = spectra2colors(spectral_reflectance, WAVELENGTHS, 'spd', 'd65', 'output', 'srgb');

% load spd of D65
spd_a = xlsread('cie.15.2004.tables.xls', 1, 'B27:B87')';
spectra = spectral_reflectance .* spd_a;

% calculate camera RGB values
[~, saturation] = responses_predict(spectra, WAVELENGTHS, camera_config.responses.params, gains, T, DELTA_LAMBDA);
cam_rgb = responses_predict(spectra/saturation, WAVELENGTHS, camera_config.responses.params, gains, T, DELTA_LAMBDA);

assert(all(lin_srgb >= 0 & lin_srgb <= 1, 'all'));
assert(all(cam_rgb >= 0 & cam_rgb <= 1, 'all'));

wb_gains = [cam_rgb(20:23, 1) \ lin_srgb(20:23, 1),...
            cam_rgb(20:23, 2) \ lin_srgb(20:23, 2),...
            cam_rgb(20:23, 3) \ lin_srgb(20:23, 3)];

cam_rgb_wb = cam_rgb .* wb_gains;

% gamma correction
srgb = lin_srgb .^ (1/2.2);
cam_rgb_wb = cam_rgb_wb .^ (1/2.2);

colors2checker({srgb, cam_rgb_wb},...
               'legend', {'Ground-Truth sRGB', 'White-Balanced Camera RGB'});

