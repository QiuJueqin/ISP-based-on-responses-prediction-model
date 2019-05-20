function [hist, whist, xlim, ylim, gird_size] = rgb2hist(rgb, ocp_params, xlim, ylim, gird_size)
% RGB2HIST generates 2D histogram in the orthogonal chromatic plane for the
% input camera RGB responses.
%
% INPUTS:
% rgb:              3-column matrix of camera raw RGB responses.
% ocp_params:       a struct containing parameters needed to convert camera
%                   RGB responses into coordinates in the orthogonal
%                   chromatic plane.
% xlim/ylim:        x- and y-range for the histogram in the orthogonal
%                   chromatic plane, both in [min, max] forms.
% gird_size:        resolution of 2D histogram.
%
% OUTPUTS:
% hist:             generated 2D histogram.
% whist:            same as 'hist', but weighted by the lightness of
%                   pixels, i.e., the brighter pixels contribute more to
%                   the histogram than the darker ones.

GAMMA = 3;

if nargin == 2
    xlim = [-0.6, 1.2];
    ylim = [-0.4, 0.6];
    gird_size = 128;
end

xy_orth = rgb2ocp(rgb, ocp_params);

% remove some invalid pixels locating outside the histogram limits
invalid_pixel_indices = (xy_orth(:, 1) <= xlim(1)) | (xy_orth(:, 1) > xlim(2)) | ...
                        (xy_orth(:, 2) <= ylim(1)) | (xy_orth(:, 2) > ylim(2));
xy_orth(invalid_pixel_indices, :) = [];
rgb(invalid_pixel_indices, :) = [];

nb_valid_pixels = size(xy_orth, 1);

% use a gamma function tn enlarge the weights for brighter pixels
lightness = (rgb * ocp_params.w) .^ GAMMA; 

% construct a 2D histogram
xedges = linspace(xlim(1), xlim(2), gird_size+1);
yedges = linspace(ylim(1), ylim(2), gird_size+1);
hist = histcounts2(xy_orth(:, 1), xy_orth(:, 2), xedges, yedges)';
% reverse Y-axis
hist = flipud(hist);

% construct a 2D histogram weighted by 'lightness'
whist = zeros(gird_size, gird_size);
hist_indices = ceil(gird_size * (xy_orth - [xlim(1), ylim(1)]) ./ [xlim(2)-xlim(1), ylim(2)-ylim(1)]);

for i = 1:nb_valid_pixels
    x_ = hist_indices(i, 1);
    y_ = hist_indices(i, 2);
    whist(y_, x_) = whist(y_, x_) + lightness(i);
end
% reverse Y-axis
whist = flipud(whist);
