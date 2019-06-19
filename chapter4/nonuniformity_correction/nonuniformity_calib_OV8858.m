% non-uniformity calibration for OmniVision OV8858

clear; close all; clc;

CAMERA_MODEL = 'OV8858';
KNOTS = [0, .15, .3, .5, .7, .85, 1];
ORDER = 3;
BIT = 16;

config = parse_data_config;

%% calculate B-spline surface parameters

contents = dir(fullfile(config.data_path, 'nonuniformity_correction\OV8858'));
params = struct([]);

for i = 3:numel(contents)
    if ~contents(i).isdir
        continue;
    end
    illuminant = contents(i).name;
    fprintf('Illuminant %s: ', illuminant);
    
    content = dir(fullfile(contents(i).folder, [contents(i).name, '\*.pgm']));
    assert(numel(content) == 1);
    raw_dir = fullfile(content.folder, content.name);
    img = pgmread(raw_dir);
    
    [coefs, gains, ~] = img2spline(img, KNOTS, ORDER);
    params(end+1).illuminant = illuminant;
    params(end).coefs = coefs;
    params(end).gains = gains;
    
    fprintf('done.\n');
end

nonuniformity_profile.params = params;

%% find maps from white-balance gains to B-spline surface parameters

M = numel(params); % number of training illuminants
N = size(params(1).coefs, 1); % N = n+1

gains = zeros(M, 2);
coefs = zeros(N, N, 3, M);
for i = 1:M
    gains(i, :) = params(i).gains([1, 3]);
    coefs(:, :, :, i) = params(i).coefs;
end

[nonuniformity_profile.components, nonuniformity_profile.maps] = gain2coefs_train(gains, coefs);

save_dir = fullfile(config.data_path, 'nonuniformity_correction\OV8858\nonuniformity_profile.mat');
save(save_dir, 'nonuniformity_profile');
