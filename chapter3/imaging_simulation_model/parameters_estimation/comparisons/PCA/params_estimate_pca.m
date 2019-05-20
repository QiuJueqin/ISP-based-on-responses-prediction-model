function [p, loss, responses_pred] = params_estimate_pca(spectra, responses, g, T, delta_lambda, ccprofile)
% PARAMS_ESTIMATE_PCA performs parameters estimation for the image
% formation model using PCA method.
%
% c.f. Jiang. et.al. What is the Space of Spectral Sensitivity Functions
% for Digital Color Cameras? 

%% data preparation
responses_norm = responses ./ g  ./ T;

WAVELENGTHS = 400:delta_lambda:720;

spectra = interp1(380:5:780, spectra', WAVELENGTHS, 'pchip')';

cam_spectra_db = dlmread('Jiang_CameraSpectralDatabase.txt');
cam_spectra_db = interp1(400:10:720, cam_spectra_db', WAVELENGTHS, 'pchip')';

N = size(cam_spectra_db, 2);

%% calculate spectral sensitivity functions using PCA

cam_spectra = zeros(N, 3);
for k = 1:3
    % spectra for one single channel
    cam_spectra_ = cam_spectra_db(k:3:end,:); 
    cam_spectra_ = cam_spectra_ ./ max(cam_spectra_, [], 2);
    
    principal_comp = pca(cam_spectra_, 'centered', 'off');
    % use first two pricipal components
    cam_spectra(:, k) = principal_comp(:, 1:2) * pinv(spectra * principal_comp(:, 1:2)) * responses_norm(:, k) / delta_lambda;
end

% clip and normalization
cam_spectra = max(cam_spectra, 0);
p.kappa = max(cam_spectra(:));
p.cam_spectra = cam_spectra / p.kappa;

%% evaluation

xyz = cc(responses,...
         ccprofile.model,...
         ccprofile.matrix,...
         ccprofile.scale);
lab = xyz2lab(100*xyz);

responses_pred = p.kappa * delta_lambda * (g .* T) .* (spectra * p.cam_spectra);
xyz_pred = cc(responses_pred,...
              ccprofile.model,...
              ccprofile.matrix,...
              ccprofile.scale);
lab_pred = xyz2lab(100*xyz_pred);

loss = ciede00(lab, lab_pred);
