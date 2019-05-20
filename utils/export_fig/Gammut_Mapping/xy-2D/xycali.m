function [xcali,ycali] = xycali(img)
[map_vert_x,map_vert_y] = mapping(img);
T = map_vert_x + map_vert_y;
[~,n] = max(T);
xcali = map_vert_x(n);
ycali = map_vert_y(n);