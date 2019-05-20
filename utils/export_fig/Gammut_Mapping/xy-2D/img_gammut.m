function [img_vert_x,img_vert_y] = img_gammut(img)
xy = rgb2xy(img);
xy = round(xy*100)/100; % 取两位小数
x = xy(:,:,1);
x = x(:);
y = xy(:,:,2);
y = y(:);
XY(:,1) = x;
XY(:,2) = y;
XY = unique(XY,'rows');
x = XY(:,1);
y = XY(:,2);
[column,row] = find(isnan(XY));
XY([column],:) = [];
k = convhull(XY(:,1),XY(:,2));
img_vert_x = x(k);
img_vert_y = y(k);
hold on;
plot(img_vert_x,img_vert_y,'r');