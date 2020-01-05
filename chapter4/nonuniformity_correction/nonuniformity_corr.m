function img_corr = nonuniformity_corr(img, wb_gains, profile, knots, order)

if nargin == 3
    knots = [0, .15, .3, .5, .7, .85, 1];
    order = 3;
end

if length(wb_gains) == 3
    wb_gains = wb_gains([1, 3]) / wb_gains(2);
end

[height, width, ~] = size(img);

components = profile.components;
maps = profile.maps;

spline_coefs = gain2coefs(wb_gains, maps, components);

compensation = coefs2surf(spline_coefs, [height, width], knots, order);

img_corr = img .* compensation;