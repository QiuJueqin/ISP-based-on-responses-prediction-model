function [map_x,map_y] = maponepoint(img_x,img_y)
load E:\Dropbox\Works\Matlab\Gammut_Mapping\xy-2D\std_vert_1.mat;
std_vert_x = std_vert_1(:,1);
std_vert_y = std_vert_1(:,2);
for i = 1:size(std_vert_x,1)
    map_x(i,1) = std_vert_x(i)/img_x;
    map_y(i,1) = std_vert_y(i)/img_y;
end
k = convhull(map_x,map_y);
map_x = map_x(k);
map_y = map_y(k);
hold on;
plot(std_vert_x,std_vert_y,'k');