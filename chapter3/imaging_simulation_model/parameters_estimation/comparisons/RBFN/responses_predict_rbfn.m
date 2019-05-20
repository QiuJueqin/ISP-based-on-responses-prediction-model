function responses = responses_predict_rbfn(params, spectra, g, T, delta_lambda)
% RESPONSES_PREDICT_PCA predicts camera raw responses for the given
% spectral radiance data using radial basis functions network.
%
% c.f. Zhao, et.al, Estimating basis functions for spectral sensitivity of
% digital cameras

WAVELENGTHS = 400:delta_lambda:720;

spectra = interp1(380:5:780, spectra', WAVELENGTHS, 'pchip')';

kappa = params.kappa;
cam_spectra = params.cam_spectra;

responses = kappa * delta_lambda * (g .* T) .* (spectra * cam_spectra);
responses = max(min(responses, 1), 0);

