function [gains, whist, whist_moved, hist_moved, whist0, hist0] =...
         npstat(rgb, ocp_params, neutral_region, xlim, ylim, grid_size)
% Neutral Pixels STATistics white-balance algorithm.
%
% INPUTS:
% rgb:              3-column matrix of camera raw RGB responses.
% ocp_params:       a struct containing parameters needed to convert camera
%                   RGB responses into coordinates in the orthogonal
%                   chromatic plane.
% neutral_region:   2-column matrix to specify the vertices of the neutral
%                   region polygon, in [x1, y1; ...; xn, yn] form.
% xlim/ylim:        x- and y-range for the histogram in the orthogonal
%                   chromatic plane, both in [min, max] forms.
% gird_size:        resolution of 2D histogram.
%
% OUTPUTS:
% gains:            estimated white-balancing gains in [Gr, Gg, Gb] form.
% whist:            the final weighted histogram, see rgb2hist.m for more
%                   details.

NEUTRAL_PIX_RATIO_THRESHOLD = 0.002;
NB_ITER_THRESHOLD = 100;

% the following default parameters are only for Nikon D3x
if nargin <= 3
    xlim = [-0.6, 1.2];
    ylim = [-0.4, 0.6];
    grid_size = 128;
end

if nargin == 2
    neutral_region = [-0.3,  0.05;...
                       0,    0.15;...
                       0.6,  0.15;...
                       0.8,  0.05;...
                       0.8, -0.05;...
                      -0.3, -0.05;...
                      -0.3,  0.05];
end

[N, C] = size(rgb);

assert(C == 3);
assert(size(neutral_region, 2) == 2);
assert(all(neutral_region >= [xlim(1), ylim(1)] & neutral_region <= [xlim(2), ylim(2)], 'all'),...
       'The neutral region must be inside the 2D histogram range.');

% ensure that the polygon is closed-loop
if ~isequal(neutral_region(1, :), neutral_region(end, :))
    neutral_region = [neutral_region; neutral_region(1, :)];
end

[hist0, whist0] = rgb2hist(rgb, ocp_params, xlim, ylim, grid_size);

% % the ratio of pixels contributed to the histogram
% valid_pix_ratio = sum(hist, 'all') / N;

neutral_region = grid_size * (neutral_region - [xlim(1), ylim(1)]) ./ [xlim(2)-xlim(1), ylim(2)-ylim(1)];
neutral_region_mask = poly2mask(neutral_region(:, 1), grid_size - neutral_region(:, 2), grid_size, grid_size);

% the ratio of the neutral pixels
neutral_pix_ratio = sum(hist0.*neutral_region_mask, 'all') / N;

% iteratively move the histogram until the number of pixels in the neutral
% region is large enough
nb_iter = 0;
move_steps = [0, 0];
steps = ceil(grid_size/128); % the number of steps to move histogram each time

hist_moved = hist0;
while neutral_pix_ratio < NEUTRAL_PIX_RATIO_THRESHOLD && nb_iter < NB_ITER_THRESHOLD
    [hist_moved, move_steps_] = move_hist(hist_moved, neutral_region_mask, steps);
    neutral_pix_ratio = sum(hist_moved.*neutral_region_mask, 'all') / N;
    
    % also record the total move steps
    move_steps = move_steps + move_steps_; % in [-y_offset, x_offset] form
    nb_iter = nb_iter + 1;
end

if neutral_pix_ratio < NEUTRAL_PIX_RATIO_THRESHOLD
    error('the ratio of neutral pixels is too small.');
end

% move the 'whist' in the same way as 'hist'
whist_moved = circshift(whist0, move_steps);

% intersection of 'whist' and 'neutral_region_mask'
whist = whist_moved .* neutral_region_mask;

% find center of mass for 'whist'
center = find_hist_center(whist, xlim, ylim);

% estimated illuminant color in camera RGB space
est_ill_rgb = ocp2rgb(center, ocp_params);

gains = est_ill_rgb(2) ./ est_ill_rgb;

end


function [hist, move_steps] = move_hist(hist, neutral_region_mask, steps)
% MOVE_HIST moves the 2D histogram toward the direction where the number of
% neutral pixels increase most fast

if nargin == 2
    steps = 1;
end

N = size(hist, 1); % grid_size

move_methods = [steps, 0;... % move the histogram down
                -steps, 0;... % move the histogram up
                0, steps;... % move the histogram right
                0, -steps;... % move the histogram left
                steps, -steps;... % move the histogram down and left
                -steps, -steps;... % move the histogram up and left
                -steps, steps;... % move the histogram up and right
                steps, steps]; % move the histogram down and right

hist_moved = zeros(N, N, 8);
for i = 1:8
    hist_moved(:, :, i) = circshift(hist, move_methods(i, :));
end

% find the direction where the number of neutral pixels increase most fast
[~, method_idx] = max(sum(hist_moved .* neutral_region_mask, [1, 2]));

hist = hist_moved(:, :, method_idx);
move_steps = move_methods(method_idx, :);

end


function xy_orth = find_hist_center(hist, xlim, ylim)
% FIND_HIST_CENTER finds center of the mass for the 2D histogram

N = size(hist, 1); % grid_size
[x_, y_] = meshgrid(1:N, 1:N);

mass = sum(hist, 'all');
center_of_mass = [sum(x_ .* hist, 'all'), sum(y_ .* hist, 'all')] / mass;
center_of_mass(2) = N + 1 - center_of_mass(2);

% reverse y-axis
xy_orth = (center_of_mass-1) / (N-1) .* [xlim(2)-xlim(1), ylim(2)-ylim(1)] + [xlim(1), ylim(1)];

end