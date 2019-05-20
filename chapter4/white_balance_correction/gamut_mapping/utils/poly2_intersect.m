function intersts = poly2_intersect(poly1, poly2)
% POLY2_INTERSECT finds intersection of two convex polygons and return
% coordinates of vertices of intersection. If there is no intersection for
% these two polygons, expand two polygon simultaneously by scale 1.5 and
% then find intersection again.
%
% Reference to
% http://capbone.com/find-the-intersection-of-convex-hull-using-matlab/
%
% NOTE: MATLAB build-in function polyxpoly() or inpolygon() has some bug,
% don't use these two function! Replace them by intersections() and
% inpoly() download from File Exchange.

if isempty(poly1) || isempty(poly2)
    intersts = [];
    return;
end

vertices = [poly1; poly2];

[intersts(:, 1), intersts(:, 2)] = intersections(poly1(:, 1), poly1(:, 2),...
                                                 poly2(:, 1), poly2(:, 2));

% keep vertices that locate in poly1 and in poly2
vertices = vertices(inpoly(vertices, poly1) & inpoly(vertices, poly2), :); 
intersts = [vertices; intersts];

if isempty(vertices)
    intersts = [];
    return;
end

intersts = [intersts; intersts(1, :)];
% make sure the coordinates of vertices locate in a clockwise order
intersts = intersts(convhull(intersts), :);

end
