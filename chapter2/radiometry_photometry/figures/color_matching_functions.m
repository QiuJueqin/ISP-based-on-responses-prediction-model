% plot CIE1931 and CIE1964 color matching functions

clear; close all; clc;

RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

cmf_1931 = xlsread('cie.15.2004.tables.xls', 4, 'A6:D86');
cmf_1964 = xlsread('cie.15.2004.tables.xls', 5, 'A6:D86');

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 20, 15]);
hold on; box on; grid on;

x_1931 = plot(cmf_1931(:,1), cmf_1931(:,2), 'linewidth', 2, 'color', RED);
y_1931 = plot(cmf_1931(:,1), cmf_1931(:,3), 'linewidth', 2, 'color', GREEN);
z_1931 = plot(cmf_1931(:,1), cmf_1931(:,4), 'linewidth', 2, 'color', BLUE);
x_1964 = plot(cmf_1964(:,1), cmf_1964(:,2), 'linewidth', 2, 'color', RED, 'linestyle', '--');
y_1964 = plot(cmf_1964(:,1), cmf_1964(:,3), 'linewidth', 2, 'color', GREEN, 'linestyle', '--');
z_1964 = plot(cmf_1964(:,1), cmf_1964(:,4), 'linewidth', 2, 'color', BLUE, 'linestyle', '--');

legend([x_1931, y_1931, z_1931, x_1964, y_1964, z_1964],...
       {'$\ \ \bar{x}(\lambda)$', '$\ \ \bar{y}(\lambda)$', '$\ \ \bar{z}(\lambda)$',...
        '$\ \ \bar{x}_{10}(\lambda)$', '$\ \ \bar{y}_{10}(\lambda)$', '$\ \ \bar{z}_{10}(\lambda)$'},...
       'interpreter', 'latex', 'fontsize', 20, 'fontname', 'times new roman', 'edgecolor', 'none');

xlim([380, 780]);
ylim([0, 2.2]);

 
xlabel('Wavelength (nm)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Sensitivity', 'fontsize', 28, 'fontname', 'times new roman');

ax = gca;
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = 420:80:740;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = 0.2:0.4:2;

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 18,...
         'xtick', 380:80:780, 'ytick', 0:0.4:3, 'ticklength', [0, 0],...
         'xminorgrid', 'on', 'yminorgrid', 'on', 'MinorGridLineStyle', ':');
