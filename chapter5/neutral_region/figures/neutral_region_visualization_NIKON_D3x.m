clear; close all; clc;

DELTA_LAMBDA = 5;
GAINS = [0.3535, 0.1621, 0.3489]; % ISO100
T = 0.01; % 10ms
XLIM = [-0.6, 1.2];
YLIM = [-0.2, 0.8];
NEUTRAL_REGION = [-0.3,  0.05;...
                   0,    0.15;...
                   0.6,  0.15;...
                   0.8,  0.05;...
                   0.8, -0.05;...
                  -0.3, -0.05;...
                  -0.3,  0.05];

RED = [255, 118, 118]/255;
CMAP = [117, 155, 186;...
        216, 61, 48;...
        252, 185, 63;...
        57, 173, 103;...
        220, 104, 146;...
        121, 119, 120]/255;

data_config = parse_data_config;
camera_config = parse_camera_config('NIKON_D3x', {'responses', 'ocp'});

% some illuminants' spds
daylight_series_wavelengths = 380:10:780;
components = xlsread('DaylightSeries.xls', 1, 'N24:P64');
coefs = xlsread('DaylightSeries.xls',1,'I15:J65');
daylight_series_spds = [ones(length(coefs), 1), coefs] * components';

black_bodies_wavelengths = 380:5:780;
temperatures = 1 ./ linspace(1/3200, 1/12000, 50);
black_bodies_spds = zeros(50, numel(black_bodies_wavelengths));
for i = 1:50
    tmp = BlackBody(temperatures(i), black_bodies_wavelengths/1E3);
    XYZ_ = spectra2colors(tmp.SpectralRadiance, black_bodies_wavelengths);
    black_bodies_spds(i, :) = tmp.SpectralRadiance/XYZ_(2);
end

cie_standard_illuminants_wavelengths = 380:5:780;
cie_standard_illuminants_spds = xlsread('cie.15.2004.tables.xls', 1, 'B23:G103')';

fluorescent_lamps_wavelengths = 380:5:780;
fluorescent_lamps_spds = [xlsread('cie.15.2004.tables.xls', 6, 'B6:M86')';...
                          xlsread('cie.15.2004.tables.xls', 6, 'B91:O171')'];
     
high_pressure_discharge_lamps_wavelengths = 380:5:780;
high_pressure_discharge_lamps_spds = xlsread('cie.15.2004.tables.xls', 7, 'B6:F86')';

led_wavelengths = 380:1:780;
led_spds = xlsread('illuminant_spds_dataset.xlsx', 1, 'CM9:KL409')';
led_ccts = xlsread('illuminant_spds_dataset.xlsx', 1, 'CM7:KL7')';
led_spds = led_spds(led_ccts >= 3300, :);

% pack into an illuminants dataset
illuminants_dataset_wavelengths = {daylight_series_wavelengths;...
                                    black_bodies_wavelengths;...
                                    cie_standard_illuminants_wavelengths;...
                                    fluorescent_lamps_wavelengths;...
                                    high_pressure_discharge_lamps_wavelengths;...
                                    led_wavelengths};

illuminants_dataset_spds = {daylight_series_spds;...
                             black_bodies_spds;...
                             cie_standard_illuminants_spds;...
                             fluorescent_lamps_spds;...
                             high_pressure_discharge_lamps_spds;...
                             led_spds};
                         
illuminants_dataset_legends = {' Daylights 4000K-12000K';...
                                ' Black Bodies 3000K-12000K';...
                                ' CIE Standard Illuminants';...
                                ' Fluorescent Lamps';...
                                ' High Pressure Discharge Lamps';...
                                ' LED Lamps'};
                            
nb_illuminant_types = numel(illuminants_dataset_spds);
illuminants_dataset_responses = cell(nb_illuminant_types, 1);
illuminants_dataset_xy_orths = cell(nb_illuminant_types, 1);
illuminants_dataset_chromaticities = cell(nb_illuminant_types, 1);

for i = 1:nb_illuminant_types
    wavelengths = illuminants_dataset_wavelengths{i};
    spds = illuminants_dataset_spds{i};
    
    illuminants_dataset_chromaticities{i} = spectra2colors(spds, wavelengths);
    
    [responses, saturation] = responses_predict(spds, wavelengths, camera_config.responses.params, GAINS, T, DELTA_LAMBDA);
    
    % adjust the amplitudes of spds to ensure the predicted responses would
    % not be onversaturated.
    if saturation >= 1
        responses = responses_predict(spds/saturation, wavelengths,...
                                      camera_config.responses.params,...
                                      GAINS, T, DELTA_LAMBDA);
    end
    assert(max(responses(:)) < 1);
    illuminants_dataset_responses{i} = responses;
    illuminants_dataset_xy_orths{i} = rgb2ocp(responses, camera_config.ocp);
end

% orthogonal chromatic plane

ocp_diagram = ocp_colorize(camera_config.ocp, XLIM, YLIM, 512);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
image(XLIM, YLIM, flipud(ocp_diagram));

hold on; box on; grid on;

for i = 1:nb_illuminant_types
    xy_orth = illuminants_dataset_xy_orths{i};
    scatter(xy_orth(:,1), xy_orth(:,2), 32, CMAP(i, :), 'filled');
end

legend(illuminants_dataset_legends,...
       'fontname', 'times new roman', 'fontsize', 18, 'box', 'off');

xlim(XLIM);
ylim(YLIM);

xlabel('$X_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');
ylabel('$Y_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');

set(gca, 'fontname', 'times new roman', 'fontsize', 22, 'linewidth', 1.5,...
         'xtick', -0.6:0.3:1.2,...
         'ydir', 'normal');


% orthogonal chromatic plane with boundary

ocp_diagram = ocp_colorize(camera_config.ocp, XLIM, YLIM, 512);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
image(XLIM, YLIM, flipud(ocp_diagram));

hold on; box on; grid on;

for i = 1:nb_illuminant_types
    xy_orth = illuminants_dataset_xy_orths{i};
    scatter(xy_orth(:,1), xy_orth(:,2), 32, CMAP(i, :), 'filled');
end

line(NEUTRAL_REGION(:,1), NEUTRAL_REGION(:,2),...
     'color', RED, 'linewidth', 3, 'linestyle', ':');

legend([illuminants_dataset_legends; ' Neutral Region Boundary'],...
       'fontname', 'times new roman', 'fontsize', 18, 'box', 'off');

xlim(XLIM);
ylim(YLIM);

xlabel('$X_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');
ylabel('$Y_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex');

set(gca, 'fontname', 'times new roman', 'fontsize', 22, 'linewidth', 1.5,...
         'xtick', -0.6:0.3:1.2,...
         'ydir', 'normal');


% cie xy diagram

hax = cie_diagram('xlim', [.1, .6], 'ylim', [.2, .6], 'saturation', .5);
hold on;
for i = 1:nb_illuminant_types
    xyz = illuminants_dataset_chromaticities{i};
    chromaticities = xyz(:, 1:2) ./ sum(xyz, 2);
    hs{i} = scatter(hax, chromaticities(:,1), chromaticities(:,2), 32, CMAP(i, :), 'filled');
end

legend([hs{:}], illuminants_dataset_legends,...
       'fontname', 'times new roman', 'fontsize', 18, 'box', 'off');

set(gcf, 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
set(gca, 'fontsize', 22);

xlabel('$x$', 'fontsize', 32, 'fontname', 'times new roman',...
       'interpreter', 'latex');
ylabel('$y$', 'fontsize', 32, 'fontname', 'times new roman',...
       'interpreter', 'latex');
   