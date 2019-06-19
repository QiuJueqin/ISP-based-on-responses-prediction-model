% prepare raw responses and spectral radiance data for SONY ILCE7
% parameters estimation

clear; close all; clc;

config = parse_data_config;

%% extract camera responses from raw images

INBIT = 12;
matraw_params = {'inbit', INBIT, 'outbit', 'same'};

contents = dir(fullfile(config.data_path, 'imaging_simulation_model\parameters_estimation\responses\ILCE7'));
for i = 3:numel(contents)
    raws_dir = fullfile(contents(i).folder, [contents(i).name, '\*.ARW']);
    if contents(i).isdir && ~contains(raws_dir, 'thumbnails')
        extract_responses(raws_dir, matraw_params{:}); % auto save
    end
end

%% extract spectral radiance data from .csv files

clearvars -except data_path;

contents = dir(fullfile(config.data_path, 'imaging_simulation_model\parameters_estimation\responses\ILCE7\*.mat'));
for i = 1:numel(contents)
    responses_dir = fullfile(contents(i).folder, contents(i).name);
    if contains(responses_dir, 'ISO_')
        extract_spectra(responses_dir);
    end
end
