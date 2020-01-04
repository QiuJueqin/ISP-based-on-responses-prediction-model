function color_diff(xyz_reference, xyz)
% compare color differences between test samples XYZ and reference samples 
% XYZ_REFERENCE on CIE1976 a*b* chromaticity plane
GRAY = [.5, .5, .5];
SCATTER_SIZE = 160;

assert(isequal(size(xyz_reference), size(xyz)));

lab_reference = xyz2lab(xyz_reference);
ab_reference = lab_reference(:, [2, 3]);
lab = xyz2lab(xyz);
ab = lab(:, [2, 3]);

hax = cie_diagram('plane', 'ab',...
                  'grid', 'on', 'xlim', [-80, 80], 'ylim', [-60, 90]);
set(gcf, 'unit', 'centimeters', 'position', [5, 5, 24, 20]);
hold on;

cdata = xyz2rgb(xyz_reference);
cdata = max(min(cdata, 1), 0);

for i = 1:size(xyz_reference, 1)
    line(hax,...
         [ab_reference(i, 1), ab(i, 1)],...
         [ab_reference(i, 2), ab(i, 2)],...
         'color', 'k', 'linewidth', 1.5);
	scatter(hax, ab_reference(i, 1), ab_reference(i, 2), SCATTER_SIZE, cdata(i, :), 'square', 'filled',...
            'markeredgecolor', 'k', 'linewidth', 1.5);
	scatter(hax, ab(i, 1), ab(i, 2), SCATTER_SIZE, cdata(i, :), '^', 'filled',...
            'markeredgecolor', 'k', 'linewidth', 1.5);
end

% phantom scatter
hs(1) = scatter(hax, inf, inf, 180, GRAY, 'square', 'filled',...
                'markeredgecolor', 'k', 'linewidth', 1.5);
hs(2) = scatter(hax, inf, inf, 180, GRAY, '^', 'filled',...
                'markeredgecolor', 'k', 'linewidth', 1.5);
legend(hs, {'Ground-Truth', 'Color Corrected'},...
       'fontname', 'times new roman', 'fontsize', 20,...
       'location', 'southwest', 'box', 'off');
end


function uv = xy2uv(xy)
assert(size(xy, 2) == 2);
u = 4*xy(:, 1) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
v = 9*xy(:, 2) ./ (-2*xy(:, 1) + 12*xy(:, 2) + 3);
uv = [u, v];
end