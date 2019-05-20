function img = raw2double(raw_dir)
% RAW2DOUBLE is a wrapper for reading a raw image with noise correction.

if contains(raw_dir, 'NIKON_D3x', 'ignorecase', true)
    inbit = 14;
elseif contains(raw_dir, 'ILCE7', 'ignorecase', true)
    inbit = 12;
else
    error(['only Nikon D3x and SONY ILCE7 are supported, ',...
           'make sure the directory path contains one of these camera model names']);
end

data_path = load('global_data_path.mat');

noise_profile_dir = findprofile(raw_dir, data_path.path);
load(noise_profile_dir);

matraw_params = {'inbit', inbit, 'outbit', 'same', 'save', false,...
                 'fpntemplate', uint16(noise_profile.mu_dark_estimate),...
                 'prnutemplate', noise_profile.K_estimate};
             
img = matrawread(raw_dir, matraw_params{:});

img = double(img) / (2^inbit-1);
