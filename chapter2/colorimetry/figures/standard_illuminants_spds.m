% plot spds of CIE standard illuminants

clear; close all; clc;

cie_illuminants = xlsread('cie.15.2004.tables.xls', 1, 'A7:G103');
fluorescent = xlsread('cie.15.2004.tables.xls', 6, 'A6:M86');

delta_lambda = 1;
wavelengths = 380 : delta_lambda : 780;

cie_illuminants = interp1(cie_illuminants(:,1), cie_illuminants(:, 2:end), wavelengths, 'spline')';
fluorescent = interp1(fluorescent(:,1), fluorescent(:, 2:end), wavelengths, 'spline')';

cie_e = ones(1, numel(wavelengths));

illuminants = [cie_illuminants; fluorescent; cie_e];

illuminant_names = {'  A', '  D50', '  D55', '  D65', '  D75',...
                    '  E', '  CWF', '  F8', '  TL84'};
illuminant_indices = [1, 4, 5, 2, 6, 19, 8, 14, 17];

illuminants = illuminants(illuminant_indices, :);

y_bar = xlsread('1924_photopic_luminous_efficiency_curve.csv');
y_bar = interp1(y_bar(:,1), y_bar(:, 2), wavelengths, 'spline');

for i = 1:numel(illuminant_names)
    % normalize spd such that Y equals 1
    spd = illuminants(i, :);
    scale = 1 / (delta_lambda * y_bar * spd');
    illuminants(i, :) = scale * spd;
end

% plot spd
colors = brewermap(numel(illuminant_names), 'spectral');
colors = hsv2rgb(rgb2hsv(colors).*[1,1,0.9]);
linestyles = {':', '-', '-.', '-', ':', '-.', ':', '-.', '-'};

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 20, 15]);
hold on; box on; grid on;

for i = 1:numel(illuminant_names)
    spd = illuminants(i, :);
    handles{i} = plot(wavelengths, spd,...
                      'linewidth', 2, 'color', colors(i, :), 'linestyle', linestyles{i});
end

legend([handles{:}], illuminant_names,...
       'fontsize', 16, 'fontname', 'times new roman', 'edgecolor', 'none');
   
xlim([380 780]);
ylim([0 0.05]);

xlabel('Wavelength (nm)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Relative Power Distribution', 'fontsize', 28, 'fontname', 'times new roman');

ax = gca;
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = 420:80:740;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = 0.005:0.01:0.045;

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 18,...
         'xtick', 380:80:780, 'ytick', 0:0.01:0.05, 'ticklength', [0, 0],...
         'xminorgrid', 'on', 'yminorgrid', 'on', 'MinorGridLineStyle', ':');
