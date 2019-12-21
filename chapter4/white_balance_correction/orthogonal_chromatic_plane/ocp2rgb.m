function rgb = ocp2rgb(xy_orth, ocp_params, varargin)
% OCP2RGB converts coordinates on orthogonal chromatic plane into camera
% RGB color space, under the assumption that G = 1, as per Eqs.(4.19) 
% and (4.20).

args = parseInput(varargin{:});
if args.reverse_y
    b = -1;
else
    b = 1;
end

[N, M] = size(xy_orth);
assert(M == 2);
assert(numel(ocp_params.w) == 3 && abs(sum(ocp_params.w)-1) <= 1E-5);
assert(numel(ocp_params.xy0) == 2);

mshear = [1, ocp_params.sigma;...
          0, b];
mrot = [cos(ocp_params.theta), -sin(ocp_params.theta);...
        sin(ocp_params.theta),  cos(ocp_params.theta)];
    
xy = xy_orth * (mshear')^-1 * (mrot')^-1 + ocp_params.xy0;

% expansion of the inverse of matrix
% M = [ (exp(x)-1)*w_r   exp(x)*w_b ]
%     [  exp(y)*w_r  (exp(y)-1)*w_b ]

determinant = ocp_params.w(1) * ocp_params.w(3) * (1-sum(exp(xy), 2)); % det of M

rb = exp(xy) .* [ocp_params.w(2)*ocp_params.w(3), ocp_params.w(2)*ocp_params.w(1)] ./ determinant;

rgb = [rb(:, 1), ones(N, 1), rb(:, 2)];

end


function args = parseInput(varargin)
parser = inputParser;
parser.PartialMatching = false;
parser.addParameter('reverse_y', true, @(x)islogical(x));
parser.parse(varargin{:});
args = parser.Results;
end