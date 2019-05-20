% noise calibration for SONY ILCE7

clear; close all;

CAMERA_MODEL = 'ILCE7';
INBIT = 12;

data_path = load('global_data_path.mat');

n1 = 16; n3 = 16; n5 = 16;
n2 = 8; n4 = 8;
matraw_params = {'inbit', INBIT, 'outbit', 'same'};

folders = {'noise_calibration\ILCE7\EXP8_ISO100_F4_55mm',...
           'noise_calibration\ILCE7\EXP15_ISO200_F4_55mm',...
           'noise_calibration\ILCE7\EXP30_ISO400_F4_55mm',...
           'noise_calibration\ILCE7\EXP60_ISO800_F4_55mm',...
           'noise_calibration\ILCE7\EXP125_ISO1600_F4_55mm'};
folders = fullfile(data_path.path, folders);

for i = 1:numel(folders)
    [~, params] = fileparts(folders{i});
    fprintf('============================================================\n');
    fprintf('Noise calibration for %s folder (%s).\n', params, CAMERA_MODEL);
    fprintf('============================================================\n');
    tic;
    
    %% estimate g0
    fprintf('Phase 1: estimating system gain (g0)...\n');

    contents = dir(fullfile(folders{i}, 'various_illumination_sets\*.ARW'));
    % get all .ARW file names
    % Note: all images must be captured in chronological order: capture n1
    % repetitions under illumination set 1, then another n1 repetitions under
    % illumination set 2, ..., until under illumination set n2.
    raw_dirs = fullfile({contents.folder}, {contents.name});
    assert(numel(raw_dirs) == n1*n2);
    raw_dirs_mat = reshape(raw_dirs, n1, n2)';

    [g0_estimate, mu_estimate_concat] = estimate_g0(raw_dirs_mat, matraw_params{:});

    fprintf('Done.\n');

    %% estimate mu_dark(i,j)
    fprintf('Phase 2: estimating dark current (mu_dark)...\n');

    contents = dir(fullfile(folders{i}, 'dark\*.ARW'));
    raw_dirs = fullfile({contents.folder}, {contents.name});
    assert(numel(raw_dirs) == n3);
    mu_dark_estimate = estimate_mu_dark(raw_dirs, matraw_params{:});

    fprintf('Done.\n');

    %% estimate K(i,j)
    fprintf('Phase 3: estimating pixel response non-uniformity (K)...\n');

    K_estimate = estimate_K(mu_estimate_concat, g0_estimate, mu_dark_estimate);
    
    pause(30);
    
    fprintf('Done.\nSaving profile...\n');

    % precision convertion for reducing size
    noise_profile.camera_model = CAMERA_MODEL;
    noise_profile.params = params;
    noise_profile.g0_estimate = double(single(g0_estimate));
    noise_profile.mu_dark_estimate = double(single(mu_dark_estimate));
    noise_profile.K_estimate = double(single(K_estimate));

    save_dir = fullfile(folders{i}, 'noise_profile.mat');
    save(save_dir, 'noise_profile', '-v7.3');
    
    clear noise_profile
    
    elapsed_time = toc;
    
    fprintf('All done. (%.1f minutes elapsed)\n', elapsed_time/60);
    
end
