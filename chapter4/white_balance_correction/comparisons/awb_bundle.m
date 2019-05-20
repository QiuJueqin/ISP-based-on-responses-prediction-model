function gains = awb_bundle(img)
% evaluate auto-white balancing performances for several algorithms

if max(img(:)) <= 1
    img = img * 255;
end
assert( max(img(:)) <= 255 || min(img(:)) >= 0);

[height, width, ~] = size(img);

while max(height, width) > 1024
    img = imresize(img, 1/2, 'bicubic');
    [height, width, ~] = size(img);
end

img = max(min(img, 255), 0);


% gray world
[r, g, b] = general_cc(img, 0, 1, 0);
gains.gray_world = [g/r, 1, g/b];


% max RGB
[r, g, b] = general_cc(img, 0, -1, 0);
gains.max_rgb = [g/r, 1, g/b];


% shades of grey
mink_norm = 5; % any number between 1 and infinity
[r, g, b] = general_cc(img, 0, mink_norm, 0);
gains.shade_of_gray = [g/r, 1, g/b];


% 1-order gray-edge
sigma = 2;        % sigma 
diff_order = 1;   % differentiation order (1 or 2)
[r, g, b] = general_cc(img, diff_order, mink_norm, sigma);
gains.gray_edge_order1 = [g/r, 1, g/b];


% 2-order gray-edge
diff_order = 2;   % differentiation order (1 or 2)
[r, g, b] = general_cc(img, diff_order, mink_norm, sigma);
gains.gray_edge_order2 = [g/r, 1, g/b];

% weng: A Novel Automatic White Balance Method For Digital Still Cameras
gains.weng = weng(img/255);

