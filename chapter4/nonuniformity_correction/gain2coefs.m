function spline_coefs = gain2coefs(wb_gains, maps, components)
% GAINS2COEFS calculates B-spline surface coefficients using white-balance
% gains, polynomial maps, and principal components.
%
% INPUTS:
% gains:          [G_r, G_b] white-balance gains
% maps:           M*M*3 polynomial tensor that maps gains to the weights of
%                 principal components.
% components:     (n+1)^2 * M * 3 principal components tensor.
%
% OUTPUTS:
% spline_coefs:   (n+1)*(n+1)*3 control points tensor for constructing
%                 B-spline surfaces.

assert(numel(wb_gains) == 2);

N = sqrt(size(components, 1)); % N = n+1

spline_coefs = zeros(N, N, 3);

polynomial = [1, wb_gains(1), wb_gains(2), wb_gains(1)^2, wb_gains(2)^2, wb_gains(1)*wb_gains(2)];
for k = 1:3
    wgt = polynomial * maps(:, :, k);
    spline_coefs_ = wgt * components(:, :, k)';
    spline_coefs(:, :, k) = reshape(spline_coefs_, N, N);
end
