function [p, loss, responses_pred] = params_estimate(spectra, responses, g, T, delta_lambda, ccprofile,...
                                                     reg_factor, smooth_threshold)
% PARAMS_ESTIMATE performs parameters estimation for the image formation
% model as introduced in Section x.x, Chapter 3 in the thesis.
% This is the core module for the imaging simulation model.
%
% INPUTS:
% spectra:          M*N spectral radiances matrix, where M is the number of
%                   training samples and N is the number of wavelengths
%                   determined by the spectroradiometer.
% responses:        M*3 responses matrix where each column corresponds to
%                   one of RGB channels (should be normalized to [0, 1] in
%                   advance).
% g:                M*3 system gains vector estimated by estimate_g0()
%                   function. If the gains are identical for all training
%                   samples, just use g = repmat(g0, M, 1) to get M
%                   duplicates.
% T:                M*1 exposure times vector (in second unit). If the
%                   exposure time are identical for all training samples,
%                   just use T = T0 * ones(M, 1) to get M duplicates.
% delta_lambda:     wavelength interval for 'spectra' in nm. If not given,
%                   it will be calculated as delta_lambda = 400/(N-1).
% ccprofile:        a struct containing necessary parameters to perform
%                   chromatic characterization.
% reg_factor:       a hyperparameter to re-adjust the weight for the
%                   regularization item based on the L-curve method.
%                   A smaller value will produce smaller residual error but
%                   more choppy camera spectral sensitivity functions.
%                   (default: 0.02)
% smooth_threshold: a hyperparameter to control the smoothness of the
%                   estimated camera spectral sensitivity functions. A
%                   smaller value will produce smoother camera spectra but
%                   lower prediction accuray. (default: 5)
%
% OUTPUTS:
% p:                estimated parameters.
% loss:             CIEDE00 color difference between predicted and
%                   ground-truth responses.
% responses_pred:   predicted responses using estimated parameters.

WAVELENGTHS = 380:5:780;

if nargin == 6
    reg_factor = 0.02;
    smooth_threshold = 5;
end

assert(isequal(size(spectra, 1),...
               size(responses, 1),...
               size(g, 1),...
               length(T)));
assert(max(responses(:))<1 && min(responses(:))>=0);

[M, N] = size(spectra);

%% Initialization

% regularization matrix
R = zeros(N-2, N);
for i = 1:N-2
    R(i,i) = -1;
    R(i,i+1) = 2;
    R(i,i+2) = -1;
end

% let initial kappa = 1
kappa0 = 1;

% initial sprctral sensitivity estimation with regularization
% NOTE: kappa is implicitly included in 'cam_spectra_sens0'
cam_spectra0 = zeros(N, 3);
fractions = responses./g;
for k = 1:3
    A_upper_block = (kappa0 * delta_lambda) * diag(T) * diag(fractions(:, k))^-1 * spectra; % M*N
    b_upper_block = ones(M, 1); % M*1
    
    % compact generalized SVD
    [U, sm, ~, ~] = cgsvd(A_upper_block, R);
    
    % find optimal lambda with l-curve tool
    hfig = figure;
    lambda = l_curve(U, sm, b_upper_block);
    close(hfig);
    
    A_lower_block = reg_factor * lambda * R; % (N-2)*N
    A = [A_upper_block; A_lower_block]; % (M+N-2)*N
    
    b_lower_block = zeros(N-2, 1); % (N-2)*1
    b = [b_upper_block; b_lower_block]; % (M+N-2)*1
    
    cam_spectra0(:, k) = lsqnonneg(A, b);
end

signal_pred = delta_lambda * diag(T) * spectra * cam_spectra0; % M*3

% predicted responses, only with camera spectral sensitivity functions
% estimation
responses_pred_lin = g .* signal_pred; 

% initial guess for nonlinear parameters and crosstalk matrix
alpha0 = zeros(1, 3);
beta0 = zeros(1, 3);
gamma0 = zeros(1, 3);
C0 = eye(3);

for k = 1:3
    % p(1) = alpha; p(2) = beta; p(3) = gamma;
    fitModel = @(p, x) g(:, k) .* real((x + p(1)).^p(3)) + p(2);
    options = optimoptions(@lsqcurvefit, 'MaxFunEvals', 1E7);
    nonl_params = lsqcurvefit(fitModel,...
                              [0; 0; 1],... % initial point
                              signal_pred(:, k),... % xdata
                              responses(:, k),... % ydata
                              [], [],... % lower and upper bounds
                              options);
	alpha0(k) = nonl_params(1);
    beta0(k) = nonl_params(2);
    gamma0(k) = nonl_params(3);
end

% predicted responses, with nonlinear function
responses_pred_nonl = g .* real((signal_pred + alpha0).*gamma0) + beta0;

%% nonlinear optimization

cam_spectra_sens_handle = @(x) reshape(x(1 : 3*N), N, 3);
alpha_handle = @(x) reshape(x(3*N+1 : 3*N+3), 1, 3);
beta_handle = @(x) reshape(x(3*N+4 : 3*N+6), 1, 3);
gamma_handle = @(x) reshape(x(3*N+7 : 3*N+9), 1, 3);
C_handle = @(x) reshape(x(3*N+10 : 3*N+18), 3, 3);
responses_pred_handle = @(x) g .* real((delta_lambda * diag(T) * spectra * cam_spectra_sens_handle(x) * C_handle(x) + alpha_handle(x)).^gamma_handle(x)) + beta_handle(x);
responses_pred_handle = @(x) max(min(responses_pred_handle(x), 1), 0);

xyz = cc(responses,...
         ccprofile.model,...
         ccprofile.matrix,...
         ccprofile.scale);
lab = xyz2lab(100*xyz);

xyz_pred_handle = @(x) cc(responses_pred_handle(x),...
                          ccprofile.model,...
                          ccprofile.matrix,...
                          ccprofile.scale);
lab_pred_handle = @(x) xyz2lab(100*xyz_pred_handle(x));

% mean ciede00 color difference as loss function
loss_handle = @(x) mean(ciede00(lab, lab_pred_handle(x)));

% initial guess
init = [cam_spectra0(:);...
        alpha0(:);...
        beta0(:);...
        gamma0(:);...
        C0(:)];

% smoothness constraints
A = [[blkdiag(R, R, R); blkdiag(-R, -R, -R)],...
     zeros(6*(N-2), 18)]; % 6(N-2) * 3N+18
b = repmat(smooth_threshold, 6*(N-2), 1); % 6(N-2) * 1

% lower- and upper-bound constraints
% cam_spectra_sens: [0, 2*cam_spectra_sens0]
% alpha: [-Inf, Inf]
% beta: [-Inf, Inf]
% gamma: [0.9, 1.1]
% C: [0, 0.1] for nondiagonal elements and [0.8, 1] for diagonal
lb = [zeros(3*N, 1);...
      5*(-sign(alpha0).*alpha0)';...
      5*(-sign(beta0).*beta0)';...
      0.8*gamma0(:);...
      0.8; 0; 0; 0; 0.8; 0; 0; 0; 0.8];
ub = [2*cam_spectra0(:);...
      5*(sign(alpha0).*alpha0)';...
      5*(sign(beta0).*beta0)';...
      1.2*gamma0(:);...
      1; 0.1; 0.1; 0.1; 1; 0.1; 0.1; 0.1; 1];


options = optimoptions(@fmincon,...
                       'MaxFunEvals', 1E6,...
                       'MaxIterations', 1E3,...
                       'Display', 'iter',...
                       'PlotFcns',@optimplotfval,...
                       'Algorithm', 'interior-point');
                   
params = fmincon(loss_handle, init, A, b, [], [], lb, ub, [], options);

cam_spectra = reshape(params(1 : 3*N), N, 3);
alpha = reshape(params(3*N+1 : 3*N+3), 1, 3);
beta = reshape(params(3*N+4 : 3*N+6), 1, 3);
gamma = reshape(params(3*N+7 : 3*N+9), 1, 3);
C = reshape(params(3*N+10 : 3*N+18), 3, 3);

p.wavelengths = WAVELENGTHS;
p.kappa0 = max(cam_spectra0(:));
p.cam_spectra0 = cam_spectra0 / p.kappa0;
p.alpha0 = alpha0;
p.beta0 = beta0;
p.gamma0 = gamma0;

p.kappa = max(cam_spectra(:));
p.cam_spectra = cam_spectra / p.kappa;
p.alpha = alpha;
p.beta = beta;
p.gamma = gamma;
p.C = C;

%% evaluation

% predicted responses only with camera spectral sensitivity functions
% estimation
xyz_pred_lin = cc(responses_pred_lin,...
                  ccprofile.model,...
                  ccprofile.matrix,...
                  ccprofile.scale);
lab_pred_lin = xyz2lab(100*xyz_pred_lin);
loss.lin = ciede00(lab, lab_pred_lin);
responses_pred.lin = responses_pred_lin;

% predicted responses with nonlinear function
xyz_pred_nonl = cc(responses_pred_nonl,...
                   ccprofile.model,...
                   ccprofile.matrix,...
                   ccprofile.scale);
lab_pred_nonl = xyz2lab(100*xyz_pred_nonl);
loss.nonl = ciede00(lab, lab_pred_nonl);
responses_pred.nonl = responses_pred_nonl;

% predicted responses by the imaging simulation model
responses_pred_optimal = responses_predict(p, spectra, g, T, delta_lambda);
xyz_pred = cc(responses_pred_optimal,...
              ccprofile.model,...
              ccprofile.matrix,...
              ccprofile.scale);
lab_pred = xyz2lab(100*xyz_pred);
loss.optimal = ciede00(lab, lab_pred);
responses_pred.optimal = responses_pred_optimal;
