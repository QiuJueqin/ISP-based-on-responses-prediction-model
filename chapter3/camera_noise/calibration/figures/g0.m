%% plot g0's w.r.t. ISO levels for NIKON D3x
% run noise_calibration_NIKON_D3x.m first to get 'noise_calib_profile.mat'
% files

clear; close all; clc;

RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [0, 128, 220]/255;

data_path = load('global_data_path.mat');

iso_levels = [100, 200, 400, 800, 1600];

folders = {'noise_calibration\NIKON_D3x\EXP8_ISO100_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP15_ISO200_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP30_ISO400_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP60_ISO800_F4_55mm',...
           'noise_calibration\NIKON_D3x\EXP125_ISO1600_F4_55mm'};
folders = fullfile(data_path.path, folders);

g0 = zeros(numel(folders), 3);
for i = 1:numel(folders)
    noise_profile_dir = fullfile(folders{i}, 'noise_profile.mat');
    noise_profile = load(noise_profile_dir);
    g0(i, :) = noise_profile.noise_profile.g0_estimate;
end

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hax = axes('position', [.16, .16, .8, .8], 'parent', hfig);

loglog(hax, iso_levels, g0(:, 1), 'color', RED, 'marker', 'o',...
     'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 12);
 
hold on; 

loglog(hax, iso_levels, g0(:, 2), 'color', GREEN, 'marker', 'o',...
     'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 12);
loglog(hax, iso_levels, g0(:, 3), 'color', BLUE, 'marker', 'o',...
     'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 12);

grid on; box on;

xlim([90, 1800]);
ylim([0.1, 10]);

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 20,...
         'xtick', iso_levels, 'ytick', [0.1, 0.2, 0.5, 1, 2, 4, 8], 'ticklength', [0, 0]);
     
xlabel('ISO Level', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Estimated Gain ($\hat{g}_0)$', 'fontsize', 26, 'fontname', 'times new roman',...
       'interpreter', 'latex');
   

%% plot g0's w.r.t. ISO levels for SONY ILCE7
% run noise_calibration_SONY_ILCE7.m first to get 'noise_calib_profile.mat'
% files

data_path = load('global_data_path.mat');

iso_levels = [100, 200, 400, 800, 1600];

folders = {'noise_calibration\ILCE7\EXP8_ISO100_F4_55mm',...
           'noise_calibration\ILCE7\EXP15_ISO200_F4_55mm',...
           'noise_calibration\ILCE7\EXP30_ISO400_F4_55mm',...
           'noise_calibration\ILCE7\EXP60_ISO800_F4_55mm',...
           'noise_calibration\ILCE7\EXP125_ISO1600_F4_55mm'};
folders = fullfile(data_path.path, folders);

g0 = zeros(numel(folders), 3);
for i = 1:numel(folders)
    noise_profile_dir = fullfile(folders{i}, 'noise_profile.mat');
    noise_profile = load(noise_profile_dir);
    g0(i, :) = noise_profile.noise_profile.g0_estimate;
end

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hax = axes('position', [.16, .16, .8, .8], 'parent', hfig);

loglog(hax, iso_levels, g0(:, 1), 'color', RED, 'marker', 'o',...
     'markerfacecolor', RED, 'linewidth', 2.5, 'markersize', 12);
 
hold on; 

loglog(hax, iso_levels, g0(:, 2), 'color', GREEN, 'marker', 'o',...
     'markerfacecolor', GREEN, 'linewidth', 2.5, 'markersize', 12);
loglog(hax, iso_levels, g0(:, 3), 'color', BLUE, 'marker', 'o',...
     'markerfacecolor', BLUE, 'linewidth', 2.5, 'markersize', 12);

grid on; box on;

xlim([90, 1800]);
ylim([0.025, 1.6]);

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 20,...
         'xtick', iso_levels, 'ytick', [0.025, 0.05, 0.1, 0.2, 0.5, 1, 1.6], 'ticklength', [0, 0]);
     
xlabel('ISO Level', 'fontsize', 26, 'fontname', 'times new roman');
ylabel('Estimated Gain ($\hat{g}_0)$', 'fontsize', 26, 'fontname', 'times new roman',...
       'interpreter', 'latex');