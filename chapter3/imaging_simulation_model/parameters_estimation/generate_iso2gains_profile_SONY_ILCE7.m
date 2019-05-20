% generate and save a profile that records system gains (g0) of different
% iso levels for SONY ILCE7

clear; close all; clc;

BIT = 12;

data_path = load('global_data_path.mat');

train_data_dirs = {'ISO100_EXP8_D65_DSG.mat',...
                   'ISO200_EXP15_D65_DSG.mat',...
                   'ISO400_EXP30_D65_DSG.mat'};
train_data_dirs = fullfile(data_path.path,...
                           'imaging_simulation_model\parameters_estimation\responses\ILCE7',...
                           train_data_dirs);

isos = [100; 200; 400];
gains = zeros(numel(train_data_dirs), 3);

for i = 1:numel(train_data_dirs)
    train_data_dir = train_data_dirs{i};
    res = load(train_data_dir);
    flags = res.result.responses_flags & res.result.spectra_flags;
    g = res.result.g(flags, :);
    tmp = g - g(1, :);
    assert(any(tmp(:)) == 0);
    gains(i, :) = g(1, :);
end

save_dir = fullfile(data_path.path,...
                    'imaging_simulation_model\parameters_estimation\responses\ILCE7\gains_profile.mat');
save(save_dir, 'isos', 'gains');
