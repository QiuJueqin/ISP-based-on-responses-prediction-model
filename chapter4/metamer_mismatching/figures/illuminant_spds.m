clear; close all; clc;

WAVELENGTHS = 380:5:780;
RED = [213 120 96]/255;
BLUE = [124 181 236]/255;

illuminant_names = {'A', 'D50', 'D100', 'CWF', 'F8', 'TL84', 'LED-D50', 'Flash'};
load('test_illuminant_spds.mat');

% daylight series simulator
ccts = xlsread('DaylightSeries.xls', 1, 'F15:F70');
bases = xlsread('DaylightSeries.xls', 1, 'N24:P64');
coefs = xlsread('DaylightSeries.xls', 1, 'I15:J70');
daylight_spds = zeros(numel(illuminant_names), numel(WAVELENGTHS));
for i = 1:numel(illuminant_names)
    xyz = spectra2colors(test_illuminant_spds(i, :), WAVELENGTHS);
    cct = xy2cct(xyz([1, 2]) / sum(xyz));
    if cct < 4000
        continue;
    end
    tmp = (bases * [1, interp1(ccts, coefs, cct, 'pchip')]')';
    tmp = interp1(380:10:780, tmp, WAVELENGTHS, 'pchip');
    xyz_ = spectra2colors(tmp, WAVELENGTHS);
    daylight_spds(i, :) = tmp / xyz_(2); % normalization
end


% plot
figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 40, 18]);
for i = 1:8
    hax = subplot(2, 4, i);
    pos = get(hax, 'OuterPosition');
    pos = pos + [-0.035, -0.01, 0.07, 0.02];
    set(hax, 'OuterPosition', pos);
    hold on; grid on;
    if sum(daylight_spds(i, :)) > 1E-6
        plot(WAVELENGTHS, daylight_spds(i, :), ':' ,...
             'linewidth', 2.5, 'color', RED);
    end
    plot(WAVELENGTHS, test_illuminant_spds(i, :),...
         'linewidth', 3, 'color', BLUE);
    set(gca, 'xtick', 380:100:780, 'ytick', 0:0.01:0.1,...
        'fontname', 'times new roman', 'fontsize', 18, 'xgrid', 'on',...
        'gridlinestyle', '--', 'linewidth', 1, 'ticklength', [0 0])
    xlim([380, 780]);
    ylim([0, 0.04]);
    if i == 6
        ylim([0, 0.05]);
    end
    
    box on;
    
    if i > 4
        xlabel('Wavelength (nm)', 'fontname', 'times new roman', 'fontsize', 22)
    end
    if i == 1 || i == 5
        ylabel('Relative SPD', 'fontname', 'times new roman', 'fontsize', 22)
    end
    text(0.055, 0.86, illuminant_names{i},...
         'units', 'normalized', 'fontname', 'times new roman',...
         'fontsize', 18);
end
