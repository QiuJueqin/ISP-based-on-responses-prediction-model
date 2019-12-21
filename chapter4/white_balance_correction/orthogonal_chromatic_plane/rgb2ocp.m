function [xy_orth, xy_rot, xy] = rgb2ocp(responses, ocp_params, varargin)
% RGB2OCP converts camera raw RGB responses in to orthogonal chromatic
% plane as per Eq.(4.18).

args = parseInput(varargin{:});
if args.reverse_y
    b = -1;
else
    b = 1;
end

assert(size(responses, 2) == 3);
assert(numel(ocp_params.w) == 3 && abs(sum(ocp_params.w)-1) <= 1E-5);
assert(numel(ocp_params.xy0) == 2);

% to logarithmic plane
xy = [log(ocp_params.w(1)*responses(:, 1) ./ (responses*ocp_params.w)),...
      log(ocp_params.w(3)*responses(:, 3) ./ (responses*ocp_params.w))]; % N*2 matrix

xy = xy - ocp_params.xy0;

% rotation  
mrot = [cos(ocp_params.theta), -sin(ocp_params.theta);...
        sin(ocp_params.theta),  cos(ocp_params.theta)];

xy_rot = xy * mrot'; % N*2 matrix

% shearing
mshear = [1, ocp_params.sigma;...
          0, b];
xy_orth = xy_rot * mshear';

end


function args = parseInput(varargin)
parser = inputParser;
parser.PartialMatching = false;
parser.addParameter('reverse_y', true, @(x)islogical(x));
parser.parse(varargin{:});
args = parser.Results;
end