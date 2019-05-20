% compare images before & after non-uniformity correction for OmniVision
% OV8858

clear; close all; clc;

data_path = load('global_data_path.mat');

profile = load(fullfile(data_path.path, 'nonuniformity_correction\OV8858\nonuniformity_profile.mat'));

pgm_name = 'Image92_4032_3024_gain1.187_shutter0.019.raw10.pgm';
gains = [1.85, 1, 2.87];

% pgm_name = 'Image96_4032_3024_gain1.629_shutter0.019.raw10.pgm';
% gains = [2.04, 1, 1.67];
% 
% pgm_name = 'Image104_4032_3024_gain4.329_shutter0.019.raw10.pgm';
% gains = [2.04, 1, 1.67];

pgm_dir = fullfile(data_path.path, 'nonuniformity_correction\OV8858', pgm_name);

img = pgmread(pgm_dir);

img_corr = nonuniformity_corr(img, gains, profile.nonuniformity_profile);

figure; imshow(img)
figure; imshow(img_corr)
