function [g0_estimate, mu_estimate_concat] = estimate_g0(raw_dirs_mat, varargin)
% ESTIMATE_G0 calculates system gain g0 as per Eq.(3.44).
%
% raw_dirs_mat:         a cell MATRIX specifying the .NEF file names
%                       (absolute dir), e.g., D_1(i,j), ..., D_N(i,j).
%                       ==================== IMPORTANT ====================
%                       Each ROW in 'raw_dirs' corresponds to one set of
%                       experiment under a specified illumination intensity.
%                       For example, if there were 8 sets of different
%                       illumination intensities and under each intensity
%                       the capturings were repeated 16 times, then
%                       'raw_dirs' should be a 8*16 cell matrix. 
% varargin:             any name-value paramter(s) supported by MatRaw
% g0_estimate:          estimated g0.

w1 = 15;

% n2 is the number of illumination sets, n1 is the repetitions in each
% illuminant set
[n2, n1] = size(raw_dirs_mat);

mu_estimate_concat = []; % will be a H*W*3*n2 tensor after concatenation
sigmaN_estimate_concat = []; % will be a H*W*3*n2 tensor after concatenation

for i = 1:n2
    % raw dirs for one illuminant set
    raw_dirs = raw_dirs_mat(i, :);
    
    % mu and sigma_N^2 for one illumination set
    [mu_estimate_map, sigmaN_estimate_map] = estimate_mu_sigmaN(raw_dirs, varargin{:});
    
    % concatenate in 4th dim
    mu_estimate_concat = cat(4, mu_estimate_concat, mu_estimate_map);
    sigmaN_estimate_concat = cat(4, sigmaN_estimate_concat, sigmaN_estimate_map);
end

kernel = ones(w1, w1) / w1^2;

% use convolution to perform local spatial mean 
% function convn() will be faster, but it lacks padding options
mu_local_mean_concat = imfilter(mu_estimate_concat, kernel, 'circular', 'same', 'conv');
sigmaN_local_mean_concat = imfilter(sigmaN_estimate_concat, kernel, 'circular', 'same', 'conv');

% the variance for the sigmaN_local_mean_maps
% see Eq.(40) in 'Radiometric CCD Camera Calibration and Noise Estimation'
sigmaN_local_mean_var_concat = 2 * (sigmaN_local_mean_concat).^2 / (w1^2 - 1);

% here use the weighted maximum likelihood estimation instead of
% (equal-weighted) maximum likelihood estimation used in my thesis.
% See Eqs.(59)-(65) in 'Radiometric CCD Camera Calibration and Noise
% Estimation'
S1 = sum(1 ./ sigmaN_local_mean_var_concat, 4); % H*W*3 matrix
S2 = sum(mu_local_mean_concat ./ sigmaN_local_mean_var_concat, 4); % H*W*3 matrix
S3 = sum(sigmaN_local_mean_concat ./ sigmaN_local_mean_var_concat, 4); % H*W*3 matrix
S4 = sum((mu_local_mean_concat.^2) ./ sigmaN_local_mean_var_concat, 4); % H*W*3 matrix
S5 = sum(mu_local_mean_concat .* sigmaN_local_mean_concat ./ sigmaN_local_mean_var_concat, 4); % H*W*3 matrix

% for each channel, g0 should be identical for all pixels, so here the
% linear regression is performed for all pixels to find a global optimal
% slope (g0)
g0_estimate = (sum(S1, [1,2]).*sum(S5, [1,2]) - sum(S2, [1,2]).*sum(S3, [1,2])) ./...
              (sum(S1, [1,2]).*sum(S4, [1,2]) - sum(S2, [1,2]).^2);
g0_estimate = squeeze(g0_estimate)';
