function luminance = luminance_estimate(img, iso, exposure_time, params, iso_profile)
% LUMINANCE_ESTIMATE (roughly) estimates the luminance (in cd/m^2) of the
% white object in the input image. Given the capturing parameters of the
% image (iso and exposure time), an optimal spectrum of the equal-energy
% radiator will be searched by minimizing the difference between the
% estimated camera responses (produced by the response prediction model)
% and the actual max intensity in the image, then the luminance of white
% object will be approximated by this optimal equal-energy radiator.

DELTA_LAMBDA = 5;
WAVELENGTHS = 380:DELTA_LAMBDA:780;

assert(max(img(:)) <= 1,...
       'input image must be double-type within range [0, 1].');
   
if ndims(img) == 3
    img = reshape(img, [], 3);
end

% assume the brightest pixels in the image correspond to the white object
brightest_pixel_indices = img(:, 2) >= prctile(img(:, 2), 99.9);
max_intensity = mean(img(brightest_pixel_indices, 2));

gains = iso2gains(iso, iso_profile);

spectra0 = ones(1, length(WAVELENGTHS)); % spectral radiance in W/(m^2*sr*nm)
[~, saturation] = responses_predict(spectra0, WAVELENGTHS, params, gains, exposure_time, DELTA_LAMBDA);
spectra0 = spectra0 / saturation;

estimated_max_intensity = @(x) responses_predict(x*spectra0, WAVELENGTHS, params, gains, exposure_time, DELTA_LAMBDA, false) * [0; 1; 0];
loss = @(x) (estimated_max_intensity(x) - max_intensity)^2;
options = optimset('MaxFunEvals', 1E6, 'MaxIter', 1E6, 'TolX', 1E-9);
scale = fminbnd(loss, 0, 5, options);
spectra = scale * spectra0; % the optimal equal-energy radiator

luminance = 683 * spectra2colors(spectra, WAVELENGTHS) * [0; 1; 0];
