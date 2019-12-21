% plot SPDs of X-Rite Macbeth SpectraLight III D65, X-Rite Macbeth
% SpectraLight III A, and 19-channel LED platform D65

clear; close all; clc;

global DELTA_LAMBDA, DELTA_LAMBDA = 5;
RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

data_config = parse_data_config;

% load spectral radiance
csv_dir = fullfile(data_config.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\D65_DSG.csv');
spd_d65 = mean(xlsread(csv_dir, 1, 'AK93:PU94'), 1);
csv_dir = fullfile(data_config.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\A_DSG.csv');
spd_A = mean(xlsread(csv_dir, 1, 'AK93:PU94'), 1);
csv_dir = fullfile(data_config.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\LED_DSG.csv');
spd_d65_led = mean(xlsread(csv_dir, 1, 'AK93:PU94'), 1);

% load spectral reflectance
reflectance = xlsread('SpectralReflectance_DSG140_SP64.csv', 1, 'Q125:AU125') / 100;
reflectance = interp1(400:10:700, reflectance, 400:5:700, 'pchip');
reflectance = [repmat(reflectance(1), 1, 4), reflectance, repmat(reflectance(end), 1, 16)];
reflectance = max(min(reflectance, 1), 0);

% interpolation and normalization
wavelengths = 380:780;
wavelengths_interp = 380:DELTA_LAMBDA:780;

spd_d65 = interp1(wavelengths, spd_d65', wavelengths_interp, 'pchip') ./ reflectance;
spd_d65 = spd_normalize(wavelengths_interp, spd_d65);
spd_A = interp1(wavelengths, spd_A', wavelengths_interp, 'pchip') ./ reflectance;
spd_A = spd_normalize(wavelengths_interp, spd_A);
spd_d65_led = interp1(wavelengths, spd_d65_led', wavelengths_interp, 'pchip') ./ reflectance;
spd_d65_led = spd_normalize(wavelengths_interp, spd_d65_led);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on; grid on; box on;
hline1 = plot(wavelengths_interp, spd_d65,...
              'color', BLUE, 'linewidth', 3, 'linestyle', '-');
hline2 = plot(wavelengths_interp, spd_A,...
              'color', RED, 'linewidth', 3, 'linestyle', ':');
hline3 = plot(wavelengths_interp, spd_d65_led,...
              'color', GREEN, 'linewidth', 3, 'linestyle', '-.');

xlim([380, 780]);
ylim([0 0.025]);

legend([hline1, hline2, hline3],...
       {' SpectraLight III D65 Simulator',...
        ' SpectraLight III A',...
        ' LED Platform D65 Simulator'},...
        'fontname', 'times new roman', 'fontsize', 20, 'box', 'off');

xlabel('Wavelength (nm)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Spectral Power Distribution', 'fontsize', 24, 'fontname', 'times new roman');

hax = gca;
hax.XAxis.MinorTick = 'on';
hax.XAxis.MinorTickValues = 430:100:730;

set(gca, 'linewidth', 2, 'fontname', 'times new roman', 'fontsize', 22,...
         'TickLabelInterpreter', 'latex',...
         'XTick', 380:100:780,...
         'ytick', 0:0.005:0.025, 'ticklength', [0, 0],...
         'xminorgrid', 'on', 'yminorgrid', 'off');
     

function spd = spd_normalize(spd_wavelengths, spd)
%%
% SPD_NORMALIZE normalizes illuminant spd such that the Y value is equal to
% 1 when observing a perfect reflecting surface
global DELTA_LAMBDA

cmfs_wavelengths = 380:5:780;
cmfs = [0.001368,0.002236,0.004243,0.007650,0.014310,0.023190,0.043510,0.077630,0.134380,0.214770,0.283900,0.328500,0.348280,0.348060,0.336200,0.318700,0.290800,0.251100,0.195360,0.142100,0.095640,0.057950,0.032010,0.014700,0.004900,0.002400,0.009300,0.029100,0.063270,0.109600,0.165500,0.225750,0.290400,0.359700,0.433450,0.512050,0.594500,0.678400,0.762100,0.842500,0.916300,0.978600,1.026300,1.056700,1.062200,1.045600,1.002600,0.938400,0.854450,0.751400,0.642400,0.541900,0.447900,0.360800,0.283500,0.218700,0.164900,0.121200,0.087400,0.063600,0.046770,0.032900,0.022700,0.015840,0.011359,0.008111,0.005790,0.004109,0.002899,0.002049,0.001440,0.001000,0.000690,0.000476,0.000332,0.000235,0.000166,0.000117,0.000083,0.000059,0.000042;...
        0.000039,0.000064,0.000120,0.000217,0.000396,0.000640,0.001210,0.002180,0.004000,0.007300,0.011600,0.016840,0.023000,0.029800,0.038000,0.048000,0.060000,0.073900,0.090980,0.112600,0.139020,0.169300,0.208020,0.258600,0.323000,0.407300,0.503000,0.608200,0.710000,0.793200,0.862000,0.914850,0.954000,0.980300,0.994950,1.000000,0.995000,0.978600,0.952000,0.915400,0.870000,0.816300,0.757000,0.694900,0.631000,0.566800,0.503000,0.441200,0.381000,0.321000,0.265000,0.217000,0.175000,0.138200,0.107000,0.081600,0.061000,0.044580,0.032000,0.023200,0.017000,0.011920,0.008210,0.005723,0.004102,0.002929,0.002091,0.001484,0.001047,0.000740,0.000520,0.000361,0.000249,0.000172,0.000120,0.000085,0.000060,0.000042,0.000030,0.000021,0.000015;...
        0.006450,0.010550,0.020050,0.036210,0.067850,0.110200,0.207400,0.371300,0.645600,1.039050,1.385600,1.622960,1.747060,1.782600,1.772110,1.744100,1.669200,1.528100,1.287640,1.041900,0.812950,0.616200,0.465180,0.353300,0.272000,0.212300,0.158200,0.111700,0.078250,0.057250,0.042160,0.029840,0.020300,0.013400,0.008750,0.005750,0.003900,0.002750,0.002100,0.001800,0.001650,0.001400,0.001100,0.001000,0.000800,0.000600,0.000340,0.000240,0.000190,0.000100,0.000050,0.000030,0.000020,0.000010,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    
assert(isrow(spd));
assert(size(cmfs, 1) == 3);
assert(numel(spd_wavelengths) == numel(spd));
assert(numel(cmfs_wavelengths) == size(cmfs, 2));

% cmfs will be temporarily resampled based on the wavelengths of spd
cmfs = interp1(cmfs_wavelengths, cmfs', spd_wavelengths, 'pchip')';
illuminant_xyz = DELTA_LAMBDA * spd * cmfs';

spd = spd / illuminant_xyz(2);
end