function [responses, saturation] = responses_predict(spectra, wavelengths, params, g, T, delta_lambda, is_cutoff)
% RESPONSES_PREDICT predicts camera raw responses for the given spectral
% radiance data using the response prediction model.
%
% INPUTS:
% spectra:          M*N spectral radiances matrix, where M is the number of
%                   training samples and N is the number of wavelengths
%                   determined by the spectroradiometer.
% wavelengths:      a vector to specify the sampling points for 'spectra',
%                   s.t. length(wavelengths) == size(spectra, 2). If it is
%                   not given ([]), the default one, [380:interval:780]
%                   will be used, where interval is inferred from
%                   'spectra'.
% params:           a struct containing parameters for the imaging
%                   simulation mode, including camera spectral sensitivity
%                   functions, kappa, nonlinear coefficients (alpha, beta,
%                   and gamma), and a crosstalk matrix. See Eq.(3.66) for
%                   the details of these parameters. 
% g:                M*3 system gains vector estimated by estimate_g0()
%                   function. If the gains are identical for all training
%                   samples, just use g = repmat(g0, M, 1) to get M
%                   duplicates.
% T:                M*1 exposure times vector (in second unit). If the
%                   exposure time are identical for all training samples,
%                   just use T = T0 * ones(M, 1) to get M duplicates.
% delta_lambda:     wavelength interval for 'spectra' in nm. If not given,
%                   it will be calculated as delta_lambda = 400/(N-1).
% is_cutoff:        set to true to cut off output image within range [0,
%                   1]. (default = true)
%
% OUTPUTS:
% responses:        N*3 matrix for the predicted camera raw responses
%                   (normalized to [0, 1]).
% saturation:       an intermediate value to indicate the maximum responses
%                   as if the dynamic range of the camera is infinite. You
%                   can adjust the capturing parameters based on this
%                   saturation values.

WAVELENGTH_RANGE = [380, 780];
WAVELENGTH_INTERVAL = 5;

if nargin < 7
    is_cutoff = true;
end

kappa = params.kappa;
cam_wavelengths = params.wavelengths;
cam_spectra = params.cam_spectra;
alpha = params.alpha;
beta = params.beta;
gamma = params.gamma;
C = params.C;

W = size(spectra, 2); % number of wavelengths

% check the input wavelengths
if isempty(wavelengths)
    wavelengths = linspace(WAVELENGTH_RANGE(1), WAVELENGTH_RANGE(2), W);
    warning('''wavelengths'' is not given. Use default values [%.5G, %.5G, ... ,%.5G].',...
            wavelengths(1), wavelengths(2), wavelengths(end));
else
    assert(isvector(wavelengths), '''wavelengths'' must be a vector.');
    if iscolumn(wavelengths)
        wavelengths = wavelengths'; % wavelengths must be a row vector
    end
    assert(numel(wavelengths) == W,...
           'the lengths of ''spectra'' and ''wavelengths'' do not match.');
end

interp_wavelengths = max([wavelengths(1), cam_wavelengths(1)]) :...
                     WAVELENGTH_INTERVAL :...
                     min([wavelengths(end), cam_wavelengths(end)]);

if interp_wavelengths(1) > wavelengths(1) || interp_wavelengths(end) < wavelengths(end)
    warning('values in spectra outside [%.5G, %.5G] wavelength range will be removed.',...
            interp_wavelengths(1),...
            interp_wavelengths(end));
end

% interpolation for spectra
if ~isequal(wavelengths, interp_wavelengths)
    spectra = interp1(wavelengths, spectra', interp_wavelengths, 'pchip')';
end

% interpolation for camera spectral sensitivity functions
if ~isequal(cam_wavelengths, interp_wavelengths)
    cam_spectra = interp1(cam_wavelengths, cam_spectra, interp_wavelengths, 'pchip');
end

% prediction
responses = g .* real((kappa * delta_lambda * diag(T) * spectra * cam_spectra * C + alpha).^gamma) + beta;

saturation = max(responses(:));

if is_cutoff
    responses = max(min(responses, 1), 0);
end

