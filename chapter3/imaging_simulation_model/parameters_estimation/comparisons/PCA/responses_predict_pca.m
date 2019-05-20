function responses = responses_predict_pca(params, spectra, g, T, delta_lambda)
% RESPONSES_PREDICT_PCA predicts camera raw responses for the given
% spectral radiance data using PCA method.
%
% c.f. Jiang. et.al. What is the Space of Spectral Sensitivity Functions
% for Digital Color Cameras? 

WAVELENGTHS = 400:delta_lambda:720;

spectra = interp1(380:5:780, spectra', WAVELENGTHS, 'pchip')';

kappa = params.kappa;
cam_spectra = params.cam_spectra;

responses = kappa * delta_lambda * (g .* T) .* (spectra * cam_spectra);
responses = max(min(responses, 1), 0);

