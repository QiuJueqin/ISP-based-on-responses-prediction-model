function  hax = cie_diagram(varargin)
% CIE_DIAGRAM draws a chromaticity diagram.
%
% INPUTS:
% colorspace:            CIE1931 color space ('cie1931', default) or
%                        CIE1976 UCS ('cie1976')
% plot_planckian_locus:  set to true to plot planckian locus. (default =
%                        false) 
% plot_planckian_labels: set to true to plot chromaticities for several
%                        black bodies. (default = false) 
% saturation:            saturation of background chromaticity diagram.
%                        (default = 1)
% xlim:                  x-axis limit in [x_lower, x_upper] form.
% ylim:                  y-axis limit in [y_lower, y_upper] form.
% parent:                parent axes handle.
%
% OUTPUTS:
% hax:                   current axes handle.

BOUNDARY_COLOR = [0, 0, 0];
PLANCKIAN_LOCUS_COLOR = [.2, .2, .2];

args = parseInput(varargin{:});

load('cie1931_cmfs.mat');

switch args.colorspace
    case 'cie1931'
        background = imread('cie1931_chromaticity_diagram.png');
        labels = {'$x$', '$y$'};
        f = @(x) x;
    case 'cie1976'
        background = imread('cie1976_ucs_chromaticity_diagram.png');
        labels = {'$a^\ast$', '$b^\ast$'};
        f = @(x) xy2uv(x);
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

image(hax, [0, 1], [0, 1], background);

hold on; axis on; box on; grid on;
boundary_chromaticities = cmfs.values(:, 1:2) ./ sum(cmfs.values, 2);
% make boundary closed-loop
boundary_chromaticities = [boundary_chromaticities; boundary_chromaticities(1, :)];

boundary_chromaticities = f(boundary_chromaticities);

line(hax,...
     boundary_chromaticities(:, 1), boundary_chromaticities(:, 2),...
     'color', BOUNDARY_COLOR, 'linewidth', 1.5);

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

xlabel(labels{1}, 'fontname', 'times new roman', 'fontsize', 48, 'interpreter', 'latex');
ylabel(labels{2}, 'fontname', 'times new roman', 'fontsize', 48, 'interpreter', 'latex');

axis equal;
xlim(args.xlim);
ylim(args.ylim);

set(gca, 'fontname', 'times new roman', 'fontsize', 20,...
    'linewidth', 1.5,...
    'xtick', 0:0.1:1, 'ytick', 0:0.1:1, 'ticklength', [0, 0],...
    'ydir', 'normal');

xgrid = get(gca,'xgridhandle');
ygrid = get(gca,'ygridhandle');
xgrid.LineWidth = 1;
ygrid.LineWidth = 1;
set(gca, 'xgridhandle', xgrid, 'ygridhandle', ygrid);

end


function args = parseInput(varargin)
parser = inputParser;
parser.PartialMatching = false;
parser.addParameter('colorspace', 'cie1931', @(x)any(strcmpi(x, {'cie1931', 'cie1976'})));
parser.addParameter('plot_planckian_locus', false, @(x)islogical(x));
parser.addParameter('plot_planckian_labels', false, @(x)islogical(x));
parser.addParameter('saturation', 1, @(x)validateattributes(x, {'numeric'}, {'nonnegative'}));
parser.addParameter('xlim', []);
parser.addParameter('ylim', []);
parser.addParameter('parent', [], @ishandle);
parser.parse(varargin{:});
args = parser.Results;
switch args.colorspace
    case 'cie1931'
        if isempty(args.xlim)
            args.xlim = [0, 0.75];
        end
        if isempty(args.ylim)
            args.ylim = [0, 0.85];
        end
    case 'cie1976'
        if isempty(args.xlim)
            args.xlim = [0, 0.65];
        end
        if isempty(args.ylim)
            args.ylim = [0, 0.6];
        end
end
end

function uv = xy2uv(xy)
assert(size(xy, 2) == 2);
u = 4*xy(:, 1) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
v = 9*xy(:, 2) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
uv = [u, v];
end