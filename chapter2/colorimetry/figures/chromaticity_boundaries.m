% plot CIE1931 and CIE1964 chromaticity boundaries

clear; close all; clc;

cmf_1931 = xlsread('cie.15.2004.tables.xls', 4, 'A6:D86');
cmf_1964 = xlsread('cie.15.2004.tables.xls', 5, 'A6:D86');
cmf_1931 = interp1(380:5:780, cmf_1931(:,2:4), 380:1:780, 'spline');
cmf_1964 = interp1(380:5:780, cmf_1964(:,2:4), 380:1:780, 'spline');

x_1931 = cmf_1931(:,1) ./ sum(cmf_1931, 2);
y_1931 = cmf_1931(:,2) ./ sum(cmf_1931, 2);

x_1931 = flipud(x_1931); % from 780nm to 380nm
y_1931 = flipud(y_1931);
x_1931 = [x_1931; x_1931(3)]; % joint line between 380nm and 770nm
y_1931 = [y_1931; y_1931(3)];

x_1964 = cmf_1964(:,1) ./ sum(cmf_1964, 2);
y_1964 = cmf_1964(:,2) ./ sum(cmf_1964, 2);

x_1964 = flipud(x_1964); % from 780nm to 380nm
y_1964 = flipud(y_1964);
x_1964 = [x_1964; x_1964(3)]; % joint line between 380nm and 770nm
y_1964 = [y_1964; y_1964(3)];

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 16, 15]);
hold on; box on; grid on;

hax_1931 = plot(x_1931, y_1931, 'b', 'linewidth', 2);
hax_1964 = plot(x_1964, y_1964, 'r', 'linewidth', 2, 'linestyle', '--');

legend([hax_1931, hax_1964],...
       {'  CIE1931 xy chromaticity boundary', '  CIE1964 xy chromaticity boundary'},...
       'fontsize', 14, 'fontname', 'times new roman', 'edgecolor', 'none');
   
axis equal;
xlim([0 0.9]);
ylim([0 0.9]);

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
