function mu_dark_estimate = estimate_mu_dark(raw_dirs, varargin)
% ESTIMATE_MU_DARK calculates dark current as per Eq.(46) in Chapter 3.

% read n3 converted dark raw images in to a tensor
converted_raws_concat = double(raws2tensor(raw_dirs, varargin{:}));

% calculate the temporal mean
mu_dark_estimate = mean(converted_raws_concat, 4);