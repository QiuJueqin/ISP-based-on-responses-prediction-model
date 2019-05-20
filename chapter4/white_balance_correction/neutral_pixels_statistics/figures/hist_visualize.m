function hhist = hist_visualize(hist, neutral_region, xlim, ylim)
% visualize histogram for tuning and debugging

RED = [255, 84, 84]/255;

if nargin <= 2
    xlim = [-0.6, 1.2];
    ylim = [-0.4, 0.6];
end

if nargin == 1
    neutral_region = [];
end

grid_size = size(hist, 1);
xedges = linspace(xlim(1), xlim(2), grid_size+1);
yedges = linspace(ylim(1), ylim(2), grid_size+1);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 18]);
hhist = histogram2('xbinedges', yedges, 'ybinedges', xedges, 'bincounts', rot90(hist, 2),...
                   'facecolor', 'flat');

if ~isempty(neutral_region)
    maximum = max(hist(:));
    hold on;
    line(neutral_region(:, 2),...
         xlim(1) + xlim(2) - neutral_region(:, 1),...
         0.01*maximum*ones(length(neutral_region), 1),...
         'color', RED, 'linewidth', 5);
end

xtick = xlim(1):0.3:xlim(2);
ytick = ylim(1):0.2:ylim(2);
set_axis(xtick, ytick, [], [1, 2, 2*max(hist(:))]);
end


function set_axis(xtick, ytick, ztick, aspect_ratio)
view(-120, 30);

cmap = brewermap(128, 'blues');
colormap(cmap(36:64, :));

xlabel('$Y_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [.1, 1.6, 0]);
ylabel('$X_{orth}$', 'fontsize', 24, 'fontname', 'times new roman',...
       'interpreter', 'latex', 'position', [-.65, .3, 0]);

xticklabels = cellfun(@num2str, num2cell(xtick(end:-1:1)), 'uniformoutput', false);

if isempty(ztick)
    ztick = get(gca, 'ztick');
end

set(gca, 'fontname', 'times new roman', 'fontsize', 22,...
         'linewidth', 1.5,...
         'xtick', ytick, 'ytick', xtick, 'ztick', ztick,...
         'yticklabels', xticklabels,...
         'dataaspectratio', aspect_ratio,...
         'projection', 'perspective');
end
