function [components, maps] = gain2coefs_train(wb_gains, spline_coefs)
% GAIN2COEFS_TRAIN finds a set of maps from white-balance gain pair [G_r,
% G_b] to B-spline surface coefficients using PCA and polynomial model.
%
% INPUTS:
% gains:          M*2 white-balance gains matrix where M is the number of
%                 training illuminants.
% spline_coefs:   (n+1)*(n+1)*3 control points tensor.
%
% OUTPUTS:
% components:     (n+1)^2 * M * 3 principal components tensor.
% maps:           M*M*3 polynomial tensor that maps gains to the weights of
%                 principal components.

NB_COMPONENTS = 6; % number of principal components
NB_POLY_ITEMS = 6;

assert(size(wb_gains, 2) == 2);
assert(ndims(spline_coefs) == 4 && size(spline_coefs, 3) == 3);

[N, ~, ~, M] = size(spline_coefs);

components = zeros(N^2, NB_COMPONENTS, 3);
maps = zeros(NB_POLY_ITEMS, NB_COMPONENTS, 3);

for k = 1:3
    coefs = squeeze(spline_coefs(:, :, k, :));
    coefs = reshape(coefs, N^2, [])';
    [components_, wgt] = pca(coefs, 'centered', 'off');
    
    % only keep first NB_COMPONENTS items
    components(:, :, k) = components_(:, 1:NB_COMPONENTS);
    wgt = wgt(:, 1:NB_COMPONENTS);
    
    polynomial = [ones(M, 1),...
                  wb_gains(:,1), wb_gains(:,2),...
                  wb_gains(:,1).^2, wb_gains(:,2).^2,...
                  wb_gains(:,1).*wb_gains(:,2)];
    assert(size(polynomial, 2) == NB_POLY_ITEMS);
    
    % least-square
    maps(:, :, k) = polynomial \ wgt;
end
