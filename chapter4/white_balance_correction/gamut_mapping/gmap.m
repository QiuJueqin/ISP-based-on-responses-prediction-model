function [illuminant_gamut, gamut_of_maps, vertices_maps, gamut_area] = gmap(rgb, ocp_params, std_gamut, std_illuminant_rgb)

% convert to [r/g, b/g] plane
rb = rgb(:, [1, 3]) ./ rgb(:, 2);

% construct current gamut given input RGBs
gamut = rb(convhull(rb), :);
gamut_area = polyarea(gamut(:, 1), gamut(:, 2));

[gamut_of_maps, vertices_maps] = find_poly_map(gamut, std_gamut);

gamut_of_maps_ = [gamut_of_maps(:, 1),...
                 ones(size(gamut_of_maps, 1), 1),...
                 gamut_of_maps(:, 2)];

candidate_illuminant_rgb = std_illuminant_rgb ./ gamut_of_maps_;

candidate_illuminant_xy_orth = rgb2ocp(candidate_illuminant_rgb, ocp_params);
illuminant_gamut = candidate_illuminant_xy_orth(convhull(candidate_illuminant_xy_orth), :);

end


function [map, vmaps] = find_poly_map(poly, std_poly)
% FIND_POLY_MAP find the map of gains from 'poly' (current gamut) to
% 'std_poly' (standard gamut).

AUGMENT_CENTER = [1, 1];
AUGMENT_RATIO = 0.05;
NB_ITER_THRESHOLD = 10;

N = size(poly, 1);

nb_iter = 0;
is_empty = true;
while is_empty && nb_iter < NB_ITER_THRESHOLD
    vmaps = cell(N, 1);
    for i = 1:N
        vmaps{i} = std_poly ./ poly(i,:);
    end       
    map = polyn_intersect(vmaps);
    if isempty(map)
        std_poly = poly_augment(std_poly, AUGMENT_CENTER, AUGMENT_RATIO);
    else
        is_empty = false;
    end
    nb_iter = nb_iter + 1;
end

end
