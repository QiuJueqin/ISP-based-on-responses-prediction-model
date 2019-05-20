function img_corr = nonuniformity_corr(img, gains, profile, knots, order)

if nargin == 3
    knots = [0, .15, .3, .5, .7, .85, 1];
    order = 3;
end

if length(gains) == 3
    gains = gains([1, 3]) / gains(2);
end

[height, width, ~] = size(img);

components = profile.components;
maps = profile.maps;

spline_coefs = gain2coefs(gains, maps, components);

compensation = coefs2surf(spline_coefs, [height, width], knots, order);

img_corr = img .* compensation;