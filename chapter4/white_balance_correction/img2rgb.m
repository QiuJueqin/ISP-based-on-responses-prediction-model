function rgb = img2rgb(img, mask_region)
% IMG2RGB reshapes a H*W*3 image into a HW*3 matrix and filters some dark
% pixels. If a mask region (e.g., region containing colorchecker) is given,
% all pixels within this region will be removed too.

SIGMA = 1.5;
SIZE = 5;
DARKNESS_THRESHOLD = 0.05;
SATURATION_THRESHOLD = 0.99;

img = imgaussian(img, SIGMA, SIZE);

if nargin == 1
    mask_region = [];
end

if ~isempty(mask_region)
    [height, width, ~] = size(img);
    % convert normalized position to absolute postion
    if all(mask_region <= 1, 'all')
        mask_region = mask_region * [width, height];
    end
    mask = ~poly2mask(mask_region(:, 1),mask_region(:, 2), height, width);
    img = img .* mask;
end

rgb = reshape(img, [], 3);
rgb(any(rgb < DARKNESS_THRESHOLD, 2) | any(rgb > SATURATION_THRESHOLD, 2), :) = [];

end