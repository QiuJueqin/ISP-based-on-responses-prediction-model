function xy = rgb2xy(rgb)
if ~strcmp(class(rgb),'double')
    rgb = im2double(rgb);
end

r = rgb(:,:,1);
g = rgb(:,:,2);
b = rgb(:,:,3);
r_small = r > 0.04045;
r(r_small) = ((r(r_small)+0.055)./1.055).^2.2;
r(~r_small) = r(~r_small) ./12.92;

g_small = g > 0.04045;
g(g_small) = ((g(g_small)+0.055)./1.055).^2.2;
g(~g_small) = g(~g_small) ./12.92;

b_small = b > 0.04045;
b(b_small) = ((b(b_small)+0.055)./1.055).^2.2;
b(~b_small) = b(~b_small) ./12.92;

x = 0.4124*r + 0.3576*g +0.1805*b;
y = 0.2126*r + 0.7152*g +0.0722*b;
z = 0.0193*r + 0.1192*g +0.9505*b;

% x = 2.7689*rgb(:,:,1)+1.7517*rgb(:,:,2)+1.1302*rgb(:,:,3);
% y = rgb(:,:,1)+4.5907*rgb(:,:,2)+0.0601*rgb(:,:,3);
% z = 0.0565*rgb(:,:,2)+5.5943*rgb(:,:,3);

xy(:,:,1) = x./(x+y+z);
xy(:,:,2) = y./(x+y+z);