function img_linear = raw2linear(img, params, g)
% RAW2LINEAR converts non-linear raw image into linear one as per Eq.(3.74).
%
% INPUTS:
% img:              input non-linear image.
% params:           a struct containing parameters for the imaging
%                   simulation mode, including camera spectral sensitivity
%                   functions, kappa, nonlinear coefficients (alpha, beta,
%                   and gamma), and a crosstalk matrix. See Eq.(65),
%                   Chapter 3 in the thesis for the details of these
%                   parameters. 
% g:                1*3 system gains vector.
%
% OUTPUTS:
% img_linear:       linear output image.

assert(isa(img, 'double'));
assert(all(img >=0 & img <= 1, 'all'));
assert(length(g) == 3);

alpha = params.alpha;
beta = params.beta;
gamma = params.gamma;
C = params.C;

if ndims(img) == 3
    % reshape to a N*3 matrix where N is the number of pixels in one channel
    [height, width, ~] = size(img);
    responses = reshape(img, height*width, 3);
else
    responses = img;
end

% inverse nonlinear function
responses_linear = g .* ( ((real(((responses - beta) ./ g) .^ (1./gamma)) - alpha)) * C^(-1) );

if ndims(img) == 3
    % reshape back to the original size
    img_linear = reshape(responses_linear, height, width, 3);
else
    img_linear = responses_linear;
end
