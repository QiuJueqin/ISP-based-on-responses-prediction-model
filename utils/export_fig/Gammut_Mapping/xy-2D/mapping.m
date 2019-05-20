function [map_vert_x,map_vert_y] = mapping(img)

[img_vert_x,img_vert_y] = img_gammut(img);
for i = 1:size(img_vert_x,1)-1
    [map_x,map_y] = maponepoint(img_vert_x(i),img_vert_y(i));

    mapping{i} = [map_x,map_y];
end
[map_vert_x,map_vert_y] = Multipolyints(mapping);


