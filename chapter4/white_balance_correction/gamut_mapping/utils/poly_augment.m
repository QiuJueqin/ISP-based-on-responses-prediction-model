function vertices = poly_augment(vertices, center, augment_ratio, is_cut_off)
% augment a polygon by 'augment_ratio' relative to its center.
%
% is_cut_off: set to true to cut off all negative values to 0+EPSILON

EPSILON = 1E-6;

if nargin == 3
    is_cut_off = true;
end

assert(size(vertices, 2) == 2);
vertices = (1+augment_ratio) * (vertices - center) + center;

if is_cut_off
    vertices = max(vertices, EPSILON);
end

end