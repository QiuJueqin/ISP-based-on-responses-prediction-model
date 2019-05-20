% plot photopic and scotopic luminous efficiency curves

clear; close all; clc;

photopic = xlsread('1924_photopic_luminous_efficiency_curve.csv');
scotopic = xlsread('1951_scotopic_luminous_efficiency_curve.csv');

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 20, 15]);
hold on; box on; grid on;

plot(photopic(:,1), photopic(:,2), 'linewidth', 2, 'color', 'r');
plot(scotopic(:,1), scotopic(:,2), 'linewidth', 2, 'color', 'b', 'linestyle', '--');

xlim([380, 780]);
ylim([0, 1]);

text(450, 0.9, '$V^\prime(\lambda)$',...
     'interpreter', 'latex', 'fontsize', 20, 'fontname', 'times new roman',...
     'horizontalalignment', 'center','backgroundcolor', 'w');
text(610, 0.9, '$V(\lambda)$',...
     'interpreter', 'latex', 'fontsize', 20, 'fontname', 'times new roman',...
     'horizontalalignment', 'center','backgroundcolor', 'w');
text(425, 0.65, sprintf('scotopic\nvision'),...
     'fontsize', 20, 'fontname', 'times new roman',...
     'horizontalalignment', 'center', 'backgroundcolor', 'w');
text(645, 0.65, sprintf('photopic\nvision'),...
     'fontsize', 20, 'fontname', 'times new roman',...
     'horizontalalignment', 'center', 'backgroundcolor', 'w');
 
xlabel('Wavelength (nm)', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Luminous Efficiency', 'fontsize', 28, 'fontname', 'times new roman');

ax = gca;
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = 420:80:740;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = 0.1:0.2:0.9;

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 18,...
         'xtick', 380:80:780, 'ytick', 0:0.2:1, 'ticklength', [0, 0],...
         'xminorgrid', 'on', 'yminorgrid', 'on', 'MinorGridLineStyle', ':');
