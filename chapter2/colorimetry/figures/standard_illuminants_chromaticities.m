% plot chromaticityies of CIE standard illuminants and Planckian locus

clear; close all; clc;

delta_lambda = 1;
wavelengths = 380 : delta_lambda : 780;

% first plot CIE1931 chromaticity boundaries
cmf_1931 = xlsread('cie.15.2004.tables.xls', 4, 'A6:D86');
cmf_1931 = interp1(380:5:780, cmf_1931(:,2:4), 380:1:780, 'spline');

x_1931 = cmf_1931(:,1) ./ sum(cmf_1931, 2);
y_1931 = cmf_1931(:,2) ./ sum(cmf_1931, 2);

x_1931 = flipud(x_1931); % from 780nm to 380nm
y_1931 = flipud(y_1931);
x_1931 = [x_1931; x_1931(3)]; % joint line between 380nm and 770nm
y_1931 = [y_1931; y_1931(3)];

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 16, 15]);
hold on; box on; grid on;

h_boundary1931 = plot(x_1931, y_1931, 'b', 'linewidth', 2);

% calculate chromaticityies for black body from 1000K to 20000K
temperatures = 1 ./ linspace(1/1000, 1/20000, 100);
special_temperatures = [2000, 3000, 5000, 10000];
temperatures = sort([temperatures, special_temperatures]);

black_body_spds = ones(numel(temperatures), numel(wavelengths));

for i = 1:numel(temperatures)
    result = BlackBody(temperatures(i), wavelengths/1000); % wavelengths in microns
    black_body_spds(i, :) = result.SpectralRadiance;
end

% plot Planckian locus
XYZ_black_body = spectra2colors(black_body_spds, wavelengths);
chromaticities_black_body = XYZ_black_body(:, 1:2) ./ sum(XYZ_black_body, 2);
h_locus = plot(chromaticities_black_body(:,1), chromaticities_black_body(:,2),...
                  'color', 'k', 'linewidth', 1.5);

% plot some special points
special_temperature_names = {'2000K', '3000K', '5000K' '10000K'};
special_temperature_indices = [54, 72, 87, 98];
chromaticities_special_black_body = chromaticities_black_body(special_temperature_indices, :);
h_special = scatter(chromaticities_special_black_body(:,1), chromaticities_special_black_body(:,2),...
                    40, 'filled', 'markerfacecolor', 'k');
text(chromaticities_special_black_body(:,1), chromaticities_special_black_body(:,2) - 0.02,...
     special_temperature_names,...
     'horizontalalignment', 'left', 'fontname', 'times new roman', 'fontsize', 16);

% calculate chromaticityies for CIE standard illuminants
cie_illuminants = xlsread('cie.15.2004.tables.xls', 1, 'A7:G103');
fluorescent = xlsread('cie.15.2004.tables.xls', 6, 'A6:M86');

cie_illuminants = interp1(cie_illuminants(:,1), cie_illuminants(:, 2:end), wavelengths, 'spline')';
fluorescent = interp1(fluorescent(:,1), fluorescent(:, 2:end), wavelengths, 'spline')';

cie_e = ones(1, numel(wavelengths));

illuminants = [cie_illuminants; fluorescent; cie_e];

illuminant_names = {'A', 'D50', 'D55', 'D65', 'D75',...
                    'E', 'CWF', 'F8', 'TL84'};
illuminant_indices = [1, 4, 5, 2, 6, 19, 8, 14, 17];

illuminants = illuminants(illuminant_indices, :);

% calculate XYZ values and chromaticities
XYZ = spectra2colors(illuminants, wavelengths);
chromaticities = XYZ(:, 1:2) ./ sum(XYZ, 2);

colors = brewermap(numel(illuminant_names), 'spectral');
colors = hsv2rgb(rgb2hsv(colors).*[1,1,0.95]);

markers = {'o', '<', '+', 'o', 's', 'd' ,'v', '*', 'x'};

for i = 1:numel(illuminant_names)
    h_cie{i} = scatter(chromaticities(i, 1), chromaticities(i, 2),...
                       180, 'filled', markers{i}, 'markerfacecolor', colors(i,:),...
                       'markeredgecolor', colors(i,:), 'linewidth', 2);
end

rectangle('position', [0.215, 0.12, 0.37, 0.11],...
          'facecolor', 'w', 'edgecolor', 'none');
[h_legend, object_h] = legendflex([h_cie{:}, h_special, h_locus, h_boundary1931],...
           [illuminant_names, 'black bodies', 'Planckian locus', 'gamut boundary'],...
           'fontsize', 16, 'fontname', 'times new roman', 'edgecolor', 'w',...
           'ncol', 3, 'box', 'off');
h_legend.Position = [120, 110, 460, 120];
axis equal;
xlim([0.2 0.6]);
ylim([0.1 0.5]);

xlabel('$x$', 'fontsize', 28, 'interpreter', 'latex');
ylabel('$y$', 'fontsize', 28, 'interpreter', 'latex');

ax = gca;
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = 0.05:0.1:0.95;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = 0.05:0.1:0.95;

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 18,...
         'xtick', 0:0.1:1, 'ytick', 0:0.1:1, 'ticklength', [0, 0],...
         'xminorgrid', 'on', 'yminorgrid', 'on', 'MinorGridLineStyle', ':');
