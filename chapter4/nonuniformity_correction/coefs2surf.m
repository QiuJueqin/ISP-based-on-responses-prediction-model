function surfaces = coefs2surf(spline_coefs, img_size, knots, order)
% COEFS2SURF constructs a set of B-spline surfaces of "img_size" sizes with
% control points ("coefs"), knots, and order
%
% INPUTS:
% spline_coefs:    (n+1)*(n+1)*3 control points tensor.
% img_size:        size of the constructed image, in [height, width] form.
% knots:           n-element spaced vector denoting the positions where
%                  the image is to be partitioned, and (n-1) is the number
%                  of sub-image blocks.
% order:           the order of 2D B-spline surface. (default = 3)
%
% OUTPUTS:
% surfaces:        constructed height*width*3 surfaces.

assert(size(spline_coefs, 3) == 3);

if nargin == 2
    knots = [0, .15, .3, .5, .7, .85, 1];
    order = 3;
end

[height, width] = deal(img_size(1), img_size(2));

knots = augknt(knots, order);

x = linspace(0, 1, width);
y = linspace(0, 1, height);

surfaces = zeros(height, width, 3);

for k = 1:3
    surfaces(:, :, k) = spcol(knots, order, y) * spline_coefs(:, :, k) * spcol(knots, order, x)';
end