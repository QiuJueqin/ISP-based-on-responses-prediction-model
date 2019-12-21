% prepare raw responses and spectral radiance data for Nikon D3x parameters
% estimation

clear; close all; clc;

data_config = parse_data_config;

%% extract camera responses from raw images

contents = dir(fullfile(data_config.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x'));
for i = 3:numel(contents)
    raws_dir = fullfile(contents(i).folder, [contents(i).name, '\*.NEF']);
    if contents(i).isdir && ~contains(raws_dir, 'thumbnails')
        extract_responses(raws_dir);
    end
end

%% extract spectral radiance data from .csv files

clearvars -except data_path;

contents = dir(fullfile(data_config.path, 'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\*.mat'));
for i = 1:numel(contents)
    responses_dir = fullfile(contents(i).folder, contents(i).name);
    if contains(responses_dir, 'ISO_')
        extract_spectra(responses_dir);
    end
end