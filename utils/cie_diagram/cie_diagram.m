function  hax = cie_diagram(varargin)
% CIE_DIAGRAM draws a chromaticity diagram.
%
% INPUTS:
% plane:                 CIE1931 xy chromaticity plane ('xy', default) or
%                        CIE1976 upvp plane ('uvp') or CIE1976 ab plane
%                        ('ab')
% plot_planckian_locus:  set to true to plot planckian locus. (default =
%                        false) 
% plot_planckian_labels: set to true to plot chromaticities for several
%                        black bodies. (default = false) 
% saturation:            saturation of background chromaticity diagram.
%                        (default = 1)
% xlim:                  x-axis limit in [x_lower, x_upper] form.
% ylim:                  y-axis limit in [y_lower, y_upper] form.
% grid:                  'on' or 'off' to specify whether to show the grids
% parent:                parent axes handle.
%
% OUTPUTS:
% hax:                   current axes handle.

BOUNDARY_COLOR = [0, 0, 0];
PLANCKIAN_LOCUS_COLOR = [.2, .2, .2];

args = parseInput(varargin{:});

switch args.plane
    case 'xy'
        background = imread('xy_diagram.png');
        bg_range = [0, 1; 0, 1];
        xtick = 0:0.1:1;
        ytick = 0:0.1:1;
        labels = {'$x$', '$y$'};
        f = @(x) x;
    case 'uvp'
        background = imread('uvp_diagram.png');
        bg_range = [0, 1; 0, 1];
        xtick = 0:0.1:1;
        ytick = 0:0.1:1;
        labels = {'$u^\prime$', '$v^\prime$'};
        f = @(x) xy2uv(x);
	case 'ab'
        background = imread('ab_diagram.png');
        bg_range = [-120, 120; -120, 120];
        xtick = -120:20:120;
        ytick = -120:20:120;
        labels = {'$a^\ast$', '$b^\ast$'};
        f = [];
end

if args.saturation ~= 1
    background_hsv = rgb2hsv(background);
    background_hsv(:, :, 2) = args.saturation * background_hsv(:, :, 2);
    background = hsv2rgb(background_hsv);
end

background = flipud(background);

if isempty(args.parent)
    figure('color', 'w', 'units','normalized','outerposition',[0, 0, 1, 1]);
    hax = axes;
else
    hax = args.parent;
end

image(hax, bg_range(1, :), bg_range(2, :), background);

hold on; axis on; box on; grid(hax, args.grid);

load('cie1931_cmfs.mat');
boundary_chromaticities = cmfs.values(:, 1:2) ./ sum(cmfs.values, 2);
% make boundary closed-loop
boundary_chromaticities = [boundary_chromaticities; boundary_chromaticities(1, :)];

if ~isempty(f)
    boundary_chromaticities = f(boundary_chromaticities);
    line(hax,...
         boundary_chromaticities(:, 1), boundary_chromaticities(:, 2),...
         'color', BOUNDARY_COLOR, 'linewidth', 1.5);
end

if args.plot_planckian_locus
    cmfs.BlackBodyChromaticity = f(cmfs.BlackBodyChromaticity);
    line(hax,...
         cmfs.BlackBodyChromaticity(:, 1), cmfs.BlackBodyChromaticity(:, 2),...
         'linewidth', 1.5, 'color', PLANCKIAN_LOCUS_COLOR);
end

if args.plot_planckian_labels
    cmfs.LabeledBlackBodyChromaticity = f(cmfs.LabeledBlackBodyChromaticity);
    scatter(hax,...
            cmfs.LabeledBlackBodyChromaticity(:,1), cmfs.LabeledBlackBodyChromaticity(:,2),...
            200, PLANCKIAN_LOCUS_COLOR, '.');
end

% show x and y axes in a*b* plane
if strcmpi(args.plane, 'ab')
    line(hax, [0, 0], [-120, 120], 'linestyle', ':', 'color', [.5, .5, .5], 'linewidth', 1);
    line(hax, [-120, 120], [0, 0], 'linestyle', ':', 'color', [.5, .5, .5], 'linewidth', 1);
end

xlabel(labels{1}, 'fontname', 'times new roman', 'fontsize', 48, 'interpreter', 'latex');
ylabel(labels{2}, 'fontname', 'times new roman', 'fontsize', 48, 'interpreter', 'latex');

axis equal;
xlim(args.xlim);
ylim(args.ylim);

set(gca, 'fontname', 'times new roman', 'fontsize', 20,...
    'linewidth', 1.5,...
    'xtick', xtick, 'ytick', ytick, 'ticklength', [0, 0],...
    'ydir', 'normal');

xgrid = get(gca,'xgridhandle');
ygrid = get(gca,'ygridhandle');
try
    xgrid.LineWidth = 1;
    ygrid.LineWidth = 1;
    set(gca, 'xgridhandle', xgrid, 'ygridhandle', ygrid);
end
end


function args = parseInput(varargin)
parser = inputParser;
parser.PartialMatching = false;
parser.addParameter('grid', 'on', @(x)ischar(x));
parser.addParameter('parent', [], @ishandle);
parser.addParameter('plane', 'xy', @(x)ischar(x));
parser.addParameter('plot_planckian_locus', false, @(x)islogical(x));
parser.addParameter('plot_planckian_labels', false, @(x)islogical(x));
parser.addParameter('saturation', 1, @(x)validateattributes(x, {'numeric'}, {'nonnegative'}));
parser.addParameter('xlim', []);
parser.addParameter('ylim', []);
parser.parse(varargin{:});
args = parser.Results;
% aliases of color space names
switch lower(args.plane)
    case {'xy', 'xyz', 'cie1931'}
        args.plane = 'xy';
        if isempty(args.xlim)
            args.xlim = [0, 0.75];
        end
        if isempty(args.ylim)
            args.ylim = [0, 0.85];
        end
	case {'uvp', 'upvp', 'uv'}
        args.plane = 'uvp';
        if isempty(args.xlim)
            args.xlim = [0, 0.65];
        end
        if isempty(args.ylim)
            args.ylim = [0, 0.6];
        end
    case {'ab', 'lab'}
        args.plane = 'ab';
        if isempty(args.xlim)
            args.xlim = [-80, 80];
        end
        if isempty(args.ylim)
            args.ylim = [-80, 100];
        end
        args.plot_planckian_locus = false;
        args.plot_planckian_labels = false;
    otherwise
        error('color space ''%s'' is not supported.', args.plane);
end
end


function uv = xy2uv(xy)
assert(size(xy, 2) == 2);
u = 4*xy(:, 1) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
v = 9*xy(:, 2) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
uv = [u, v];
end
