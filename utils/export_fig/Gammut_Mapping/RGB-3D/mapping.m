function intersection_vertices = mapping(img_vert_set)
if size(img_vert_set,2) ~=3
    error('image vertices set must be 3-column.');
end
intersection_vertices = [];

flag = 0;
extend = 1;
while isempty(intersection_vertices)
    A_total = [];
    b_total = [];
    
    for i = 1:size(img_vert_set,1)

        img_vert_rgb = img_vert_set(i,:);
        map_polyhedron_vert = img_map(img_vert_rgb);  
        if flag == 1
            map_polyhedron_vert = polyexpand(map_polyhedron_vert,extend);
            disp('Gammut has been expanded.');
        end

    %     k = convhulln(map_polyhedron_vert);
    %     hold on;trisurf(k,map_polyhedron_vert(:,1),map_polyhedron_vert(:,2),map_polyhedron_vert(:,3),'facealpha',0.1);
        [A,b] = vert2lcon(map_polyhedron_vert);
        A_total = [A_total;A];
        b_total = [b_total;b];
    end
    intersection_vertices = lcon2vert(A_total,b_total);
    flag = 1;
    extend = extend *1.5;
end

function after_expand = polyexpand(before_expand,extend)
x = before_expand(:,1);
y = before_expand(:,2);
z = before_expand(:,3);
x_center = sum(x(:))/size(before_expand,1);
y_center = sum(y(:))/size(before_expand,1);
z_center = sum(z(:))/size(before_expand,1);
x = extend * x + (1-extend) * x_center;
y = extend * y + (1-extend) * y_center;
z = extend * z + (1-extend) * z_center;
after_expand = [x,y,z];

