clear; close all; clc;

DELTA_LAMBDA = 5;
WAVELENGTHS = 400:DELTA_LAMBDA:700;
MIN_ENERGY_THRESHOLD = 0.02;
SATURATION_THRESHOLD = 30;
DARKNESS_THRESHOLD = 0.01;
AUGMENT_CENTER = [1.5, 1];
AUGMENT_RATIO = 0.05;
K = 200;
GAINS = [0.3535, 0.1621, 0.3489]; % ISO100
T = 0.01; % 10ms exposure time
RED = [255, 84, 84]/255;

config = parse_data_config;

spectral_reflectances_database = xlsread('spectral_reflectances_database.xlsx', 1, 'D3:CF9272');
% keep only 400-700nm
spectral_reflectances_database = spectral_reflectances_database(:, 5:end-16);
spectral_reflectances_database(any(spectral_reflectances_database < 0, 2), :) = [];

% remove those samples with lowest energies
xyz = spectra2colors(spectral_reflectances_database, WAVELENGTHS, 'spd', 'd65');
xyz(xyz(:, 2) < MIN_ENERGY_THRESHOLD , :) = [];
spectral_reflectances_database(xyz(:, 2) < MIN_ENERGY_THRESHOLD , :) = [];


%% visualize spectral reflectance

lab = xyz2lab(xyz);
saturation = sqrt(sum(lab(:, [2, 3]).^2, 2));

% remove those samples with lowest saturation
spectra = spectral_reflectances_database(saturation >= SATURATION_THRESHOLD, :);

N = size(spectra, 1);
indices = randperm(N, K);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
hold on; grid on; box on;
for i = 1:K
    ref = spectra(indices(i), :);
    
    color = xyz2rgb(spectra2colors(ref, WAVELENGTHS, 'spd', 'd65'));
    color = max(min(color, 1), 0);
    
    plot(WAVELENGTHS, ref, 'color', color, 'linewidth', .5);
end

set(gca, 'fontname', 'times new roman', 'fontsize', 22, 'linewidth', 1.5,...
         'xtick', 400:50:700, 'ytick', 0:0.2:1, 'ticklength', [0, 0]);

xlabel('Wavelength (nm)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Spectral Reflectance', 'fontsize', 26, 'fontname', 'times new roman');
   
   
%% visualize standard gamut

% load parameters of imaging simulation model
params_dir = fullfile(config.data_path,...
                      'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
load(params_dir);

std_illuminant_spd = xlsread('cie.15.2004.tables.xls',1,'C23:C83')'; % D65

spectra = std_illuminant_spd .* spectral_reflectances_database;
xyz = spectra2colors(spectra, WAVELENGTHS);
colors = max(min(xyz2rgb(1.2 * xyz / max(xyz(:))), 1), 0);

[~, saturation] = responses_predict(spectra, WAVELENGTHS, params, GAINS, T, DELTA_LAMBDA);
responses = responses_predict(spectra/saturation, WAVELENGTHS, params, GAINS, T, DELTA_LAMBDA);

darkness_indices = any(responses < DARKNESS_THRESHOLD, 2);
responses(darkness_indices, :) = [];
colors(darkness_indices, :) = [];

rb = responses(:, [1, 3]) ./ responses(:, 2);
vertices = rb(convhull(rb), :);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
hold on; grid on; box on;
scatter(rb(:, 1), rb(:, 2), 8, colors, 'FILLED');
hlines(1) = line(vertices(:, 1), vertices(:, 2), 'color', RED, 'linewidth', 3);

xlim([0, 5]);
ylim([0, 2.5]);

vertices = poly_augment(vertices, AUGMENT_CENTER, AUGMENT_RATIO);
hlines(2) = line(vertices(:, 1), vertices(:, 2), 'color', RED, 'linewidth', 3, 'linestyle', ':');

legend(hlines,...
       {' Standard Gamut', ' Standard Gamut (Augmented)'},...
       'fontsize', 24, 'fontname', 'times new roman', 'edgecolor', 'none');

set(gca, 'fontname', 'times new roman', 'fontsize', 22, 'linewidth', 1.5,...
         'xtick', 0:1:5, 'ytick', 0:0.5:2.5);

xlabel('$\frac{D_r}{D_g}$', 'fontsize', 32, 'fontname', 'times new roman',...
       'interpreter', 'latex');
ylabel('$\frac{D_b}{D_g}$', 'fontsize', 32, 'fontname', 'times new roman',...
       'interpreter', 'latex');