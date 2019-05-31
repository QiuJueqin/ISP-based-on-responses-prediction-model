function intersection = polyn_intersect(polygons)
% POLYN_INTERSECT finds intersection of multiple polygons using a recursive
% procedure
%
% INPUTS:
% polygons:       a N-element cell array containing vertices of N polygons

assert(iscell(polygons));

if any(cellfun(@isempty, polygons))
    intersection = [];
    return;
end

% make sure every polygon is closed-loop
polygons = cellfun(@complete_poly, polygons, 'uniformoutput', false);

if numel(polygons) == 1
    intersection = polygons{1};
elseif numel(polygons) == 2
    intersection = poly2_intersect(polygons{1}, polygons{2});
else
    polygons_group1 = polygons(1:ceil(numel(polygons)/2));
    polygons_group2 = polygons(ceil(numel(polygons)/2)+1:end);
    intersection_group1 = polyn_intersect(polygons_group1);
    intersection_group2 = polyn_intersect(polygons_group2);
    intersection = poly2_intersect(intersection_group1, intersection_group2);
end

end


function poly = complete_poly(poly)
assert(size(poly, 2) == 2);
if ~isequal(poly(1, :), poly(end, :))
    poly = [poly; poly(1, :)];
end
end
