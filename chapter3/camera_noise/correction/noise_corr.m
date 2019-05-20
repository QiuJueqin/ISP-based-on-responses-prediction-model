function raw_noise_corrected = noise_corr(raw, profile)
% NOISE_CORR corrects the system noise in the input raw image.
%
% raw:        converted raw image returned by 
%             double(matrawread(rawdir, 'cfa', X,...
%                               'inbit', X, 'outbit', 'same')).
% profile:    noise correction profile containing estimated mu_dark(i,j)
%             and estimated K(i,j).

assert(isequal(size(raw), size(profile.mu_dark_estimate)));
assert(isequal(size(raw), size(profile.K_estimate)));

% see Eq.() in Chapter 3
raw_noise_corrected = (raw - profile.mu_dark_estimate) ./ profile.K_estimate;
