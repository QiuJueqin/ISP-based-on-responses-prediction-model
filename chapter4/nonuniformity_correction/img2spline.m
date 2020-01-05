function [coefs, wb_gains, img_corr] = img2spline(img, knots, order)
% IMG2SPLINE calculates B-spline surface parameters for non-uniformity
% calibration given the input image using 2D B-spline surface fitting.
%
% INPUTS:
% img:          H*W*3 image of uniform object
% knots:        n-element spaced vector denoting the positions where
%               the image is to be partitioned, and (n-1) is the number of
%               sub-image blocks.
% order:        the order of 2D B-spline surface. (default = 3)
%
% OUTPUTS:
% coefs:        B-spline surface parameters.
% wb_gains:     white-balance gains [G_r, G_g, G_b].
% img_corr:     nonuniformity corrected image.

if nargin == 1
    knots = [0, .15, .3, .5, .7, .85, 1];
    order = 3;
end
knots = augknt(knots, order);

[height, width, ~] = size(img);

% 4% central region of image is regarded as homogeneous and non-shading,
% which will be used to calculate white-balance gains
roi = img(round(0.49*height) : round(0.51*height),...
          round(0.49*width) : round(0.51*width),...
          :);
roi_mean = mean(roi, [1, 2]);

reciprocal = roi_mean ./ img;
reciprocal = max(reciprocal, 1);

N = length(knots) - order;
coefs = zeros(N, N, 3);
reciprocal_fit = zeros(size(reciprocal));

% least-squares spline fitting
x = linspace(0, 1, width);
y = linspace(0, 1, height);
for k = 1:3
    sp_y = spap2(knots, order, x, reciprocal(:, :, k));
    coefs_tmp = fnbrk(sp_y, 'coefs');
    sp_x = spap2(knots, order, y, coefs_tmp');
    coefs(:, :, k) = fnbrk(sp_x, 'coefs')';
    reciprocal_fit(:, :, k) = spcol(knots, order, y) * coefs(:, :, k) * spcol(knots, order, x)';
end

img_corr = img .* reciprocal_fit;

wb_gains = roi_mean(2) ./ squeeze(roi_mean)';
