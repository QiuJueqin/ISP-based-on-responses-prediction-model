function gamut_visualize(scatters, std_gamut, is_scatter_shown, labels)
% visualize 2D or 3D color gamut given input coordinates.

D = size(scatters, 2); % dimension

if nargin <= 3
    labels = cell(1, 3);
else
    assert(iscell(labels));
end

if nargin <= 2
    is_scatter_shown = true;
end

if nargin == 1
    std_gamut = [];
end

if ~isempty(std_gamut)
    assert(D == size(std_gamut, 2));
end

switch D
    case 2
        gamut_visualize_2d(scatters, std_gamut, is_scatter_shown, labels);
    case 3
        gamut_visualize_3d(scatters, std_gamut, is_scatter_shown, labels);
    otherwise
        error('the sample points can only be 2- or 3-dimension.');
end

end


function gamut_visualize_2d(scatters, std_gamut, is_scatter_shown, labels)

MAXIMUM_SCATTERS = 2E4;
RED = [255, 84, 84]/255;
GREEN = [0, 204, 102]/255;
BLUE = [53, 103, 124]/255;

N = size(scatters, 1);

k = convhull(scatters);

insiders = scatters(setdiff(1:N, k), :);

Ni = size(insiders, 1);
if Ni > MAXIMUM_SCATTERS
    insiders = insiders(randperm(Ni, MAXIMUM_SCATTERS), :);
end

scatters = [scatters; insiders];

gamut = scatters(convhull(scatters), :);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
hold on; grid on; box on;

if is_scatter_shown
    scatter(scatters(:, 1), scatters(:, 2), 6, 'filled',...
            'markeredgecolor', BLUE, 'markerfacecolor', BLUE);
end

hlines(1) = line(gamut(:, 1), gamut(:, 2),...
                 'color', GREEN, 'linewidth', 2);
legends{1} = ' Gamut of Image';

if ~isempty(std_gamut)
    hlines(2) = line(std_gamut(:, 1), std_gamut(:, 2),...
                     'color', RED, 'linewidth', 2);
    legends{2} = ' Standard Gamut';
end

legend(hlines, legends,...
       'fontsize', 24, 'fontname', 'times new roman', 'edgecolor', 'none');

xlabel(labels{1}, 'fontsize', 26, 'fontname', 'times new roman',...
       'interpreter', 'latex');
ylabel(labels{2}, 'fontsize', 26, 'fontname', 'times new roman',...
       'interpreter', 'latex');

set(gca, 'fontname', 'times new roman', 'fontsize', 22,...
         'linewidth', 1.5);

end


function gamut_visualize_3d(scatters, std_gamut, is_scatter_shown, labels)
    
CMAP = brewermap(128, 'spectral');
CMAP = CMAP(32:96, :);
STD_CMAP = brewermap(128, 'blues');
STD_CMAP = STD_CMAP(32:96, :);
EDGECOLOR = [.5, .5, .5];
SCATTERCOLOR = [53, 103, 124]/255;
FACEALPHA = .6;
MAXIMUM_SCATTERS = 500;
MAXIMUM_VERTICES = 30;

N = size(scatters, 1);

k = convhull(scatters);

vertices = scatters(k, :);
insiders = scatters(setdiff(1:N, k), :);

if size(vertices, 1) > MAXIMUM_VERTICES
    [~, vertices] = kmeans(vertices, MAXIMUM_VERTICES);
end

Ni = size(insiders, 1);
if Ni > MAXIMUM_SCATTERS
    insiders = insiders(randperm(Ni, MAXIMUM_SCATTERS), :);
end

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
hold on; grid on;

if is_scatter_shown
    scatter3(insiders(:, 1), insiders(:, 2), insiders(:, 3), 6, 'filled',...
             'markeredgecolor', SCATTERCOLOR, 'markerfacecolor', SCATTERCOLOR);
end

kv = convhull(vertices);
hpoly = trisurf(kv, vertices(:, 1), vertices(:, 2), vertices(:, 3));

colormap(CMAP);
set(hpoly, 'facecolor', 'interp', 'linewidth', 1,...
           'facealpha', FACEALPHA, 'edgecolor', EDGECOLOR);

if ~isempty(std_gamut)
    figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
    hold on;

    ks = convhull(std_gamut);
    hpoly_std = trisurf(ks, std_gamut(:, 1), std_gamut(:, 2), std_gamut(:, 3));
    colormap(STD_CMAP);
    set(hpoly_std, 'facealpha', FACEALPHA, 'edgecolor', EDGECOLOR);
end

view(-30, 30);
axis equal;

set(gca, 'fontname', 'times new roman', 'fontsize', 22,...
         'linewidth', 1.5,...
         'projection', 'perspective');
hax = gca;

xlabel(labels{1}, 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [mean(hax.XLim),...
                                            hax.YLim(1)-0.2*(hax.YLim(2)-hax.YLim(1)),...
                                            0]);
ylabel(labels{2}, 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [hax.XLim(1)-0.2*(hax.XLim(2)-hax.XLim(1)),...
                                            mean(hax.YLim),...
                                            0]);
zlabel(labels{3}, 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [hax.XLim(1)-0.15*(hax.XLim(2)-hax.XLim(1)),...
                                            hax.YLim(2)+0.15*(hax.YLim(2)-hax.YLim(1)),...
                                            mean(hax.ZLim)]);
end
