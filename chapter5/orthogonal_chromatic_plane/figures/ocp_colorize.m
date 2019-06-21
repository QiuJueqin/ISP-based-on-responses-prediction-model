function ocp_diagram = ocp_colorize(ocp_params, xlim, ylim, ppul, matrix, varargin)
% generate a chromaticity diagram in sRGB for orthogonal chromatic plane.
%
% ppul:         pixels per unit length in ocp.
% matrix:       a matrix that converts camera raw RGB responses into XYZ
%               color space.

CC_MODEL = 'root6x3';

if nargin == 1
	xlim = [-0.6, 1.2];
    ylim = [-0.4, 0.6];
    ppul = 512;
end

if nargin <= 4 || isempty(matrix)
    % color conversion matrix only for Nikon D3x
    matrix = [0.9513, 0.3049, -0.1591;...
              0.2421, 0.8694, 0.0919;...
              0.4835, -0.0075, 2.1614;...
              0.7534, 0.5237, 0.1571;...
              0.0549, -0.0337, 0.5443;...
             -0.6931, -0.3954, -1.2037];
end

width = ceil(ppul*(xlim(2) - xlim(1)));
height = ceil(ppul*(ylim(2) - ylim(1)));

x_ = linspace(xlim(1), xlim(2), width);
y_ = linspace(ylim(2), ylim(1), height);

[x_, y_] = meshgrid(x_, y_);
xy_orth = [x_(:), y_(:)];

rgb = ocp2rgb(xy_orth, ocp_params, varargin{:}); % camera RGB responses

rgb = rgb/max(rgb(:));

xyz_pred = ccmapply(rgb,...
                    CC_MODEL,...
                    matrix);

% equalize lightness for all coordinates in orthogonal chromatic plane and
% convert into sRGB color space
lab_pred = xyz2lab(xyz_pred);
lab_pred(:,1) = 98;

srgb_pred = max(min(lab2rgb(lab_pred), 1), 0);

ocp_diagram = reshape(srgb_pred, height, width, 3);
