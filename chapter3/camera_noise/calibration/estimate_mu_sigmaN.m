function [mu_estimate, sigmaN_estimate] = estimate_mu_sigmaN(raw_dirs, varargin)
% ESTIMATE_MU_SIGMAN calculates temporal mean as well as temporal % sample
% variance for total noise as per Eqs.(3.36) and (3.37).
%
% raw_dirs:             a cell specifying the .NEF file names (absolute
%                       dir), e.g., D_1(i,j), ..., D_N(i,j).
% varargin:             any name-value paramter(s) supported by MatRaw
% mu_estimate_map:      estimated mu map with the same size as each of
%                       D_p(i,j).
% sigmaN_estimate_map:  estimated sigma_N^2 map with the same size as each
%                       of D_p(i,j).

n1 = numel(raw_dirs);

% read n1 converted raw images in to a tensor
converted_raws_concat = double(raws2tensor(raw_dirs, varargin{:}));

% calculate their temporal mean
mu_estimate = mean(converted_raws_concat, 4);

% calculate variance
sigmaN_estimate = sum((converted_raws_concat - mu_estimate).^2, 4) / (n1-1);
