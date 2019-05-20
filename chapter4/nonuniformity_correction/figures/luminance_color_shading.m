% plot the response falloff in a non-uniform image

clear; close all; clc;

HEIGHT = 1560;
WIDTH = 2104;

data_path = load('global_data_path.mat');

%% luminance shading

load(fullfile(data_path.path, 'nonuniformity_correction\OV8858\nonuniformity_profile.mat'));
coefs = nonuniformity_profile.params(5).coefs;

knots = [0, .15, .3, .5, .7, .85, 1];
order = 3;
knots = augknt(knots, order);

x = linspace(0, 1, WIDTH);
y = linspace(0, 1, HEIGHT);

luminance_shading = 1 ./ (spcol(knots, order, y) * coefs(:, :, 2) * spcol(knots, order, x)');
luminance_shading = luminance_shading / max(luminance_shading(:));

figure; imshow(luminance_shading);


%% color shading

clearvars -except HEIGHT WIDTH data_path nonuniformity_profile knots order x y luminance_shading

coefs = nonuniformity_profile.params(3).coefs;

color_shading = zeros(HEIGHT, WIDTH, 3);
for k = 1:3
    color_shading_ = 1 ./ (spcol(knots, order, y) * coefs(:, :, k) * spcol(knots, order, x)');
	color_shading(:, :, k) = color_shading_ / max(color_shading_(:));
end

figure; imshow(color_shading);