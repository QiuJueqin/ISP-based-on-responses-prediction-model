function [p, loss, responses_pred] = params_estimate_rbfn(spectra, responses, g, T, delta_lambda, ccprofile)
% PARAMS_ESTIMATE_PCA performs parameters estimation for the image
% formation model using radial basis functions network.
%
% c.f. Zhao, et.al, Estimating basis functions for spectral sensitivity of
% digital cameras

%% data preparation
responses_norm = responses ./ g  ./ T;

WAVELENGTHS = 400:delta_lambda:720;

spectra = interp1(380:5:780, spectra', WAVELENGTHS, 'pchip')';

cam_spectra_db = dlmread('Jiang_CameraSpectralDatabase.txt');
cam_spectra_db = interp1(400:10:720, cam_spectra_db', WAVELENGTHS, 'pchip')';

N = size(cam_spectra_db, 2);

%% calculate spectral sensitivity functions using PCA

cam_spectra = zeros(N, 3);
center_wavelength = [600, 540, 460];
for k = 1:3
    % spectra for one single channel
    cam_spectra_ = cam_spectra_db(k:3:end,:); 
    cam_spectra_ = cam_spectra_ ./ max(cam_spectra_, [], 2);
    
    rbf = RBFFitting(WAVELENGTHS', cam_spectra_', 7, center_wavelength(k));
    coefs = lsqnonneg(spectra * rbf, responses_norm(:, k));
    cam_spectra(:, k) = rbf * coefs / delta_lambda;
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
end


function [RBF, Coefs,Mu_Opt,sigma_Opt] = RBFFitting(X,P,N,center)
sigma0 = (max(X)-min(X))/(N+1);
Mu0 = center-(N-1)*sigma0/2 : sigma0 : center+(N-1)*sigma0/2;
% x(1): central wavelength of the center gauss function
% x(2): wavelength interval of two adjacent gauss functions
% x(3): sigma
B = @(x) GaussFncSetCreate(X,N,[x(1)-(N-1)*x(2)/2 : x(2) : x(1)+(N-1)*x(2)/2], x(3));
P_est = @(x) B(x)*pinv(B(x))*P;
costfun = @(x) mean2((P-P_est(x)).^2);
A = [-1 (N-1)/2 0;...
      1 (N-1)/2 0;...
      0 -1.5 1];
b = [0; 780; 0];
% Three constraints:
% 1. x(1)-(N-1)*x(2)/2 > 0
% 2. x(1)+(N-1)*x(2)/2 < 780
% 3. x(3) < 1.5*x(2)
Opt = fmincon(costfun,[center;sigma0;sigma0],A,b);
Mu_Opt = Opt(1)-(N-1)*Opt(2)/2 : Opt(2) : Opt(1)+(N-1)*Opt(2)/2;
sigma_Opt = Opt(3);
clear B P_est
RBF = GaussFncSetCreate(X,N,Mu_Opt,sigma_Opt);
Coefs = pinv(RBF)*P;
end

function F = GaussFncSetCreate(X,N,Mu,sigma)
F = zeros(length(X),N);
for i = 1:N
    F(:,i) = exp(-(X-Mu(i)).^2/(sigma^2));
end
end


