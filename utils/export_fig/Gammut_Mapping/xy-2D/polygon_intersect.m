function [ints_x,ints_y,poly1_x,poly1_y,poly2_x,poly2_y] = polygon_intersect(poly1_x,poly1_y,poly2_x,poly2_y)
% 求两个个凸多边形的交集
% poly1_x,poly1_y 分别为第一个多边形的各个顶点的x,y坐标，均为列向量
% poly2_x,poly2_y 分别为第二个多边形的各个顶点的x,y坐标，均为列向量

% ********************************************************** %
% 1.Let S be the set of vertices from both polygons.
% 2.For each edge e1 in polygon 1
%     1.For each edge e2 in polygon 2
%         1.If e1 intersects with e2
%             1.Add the intersection point to S
% 3.Remove all vertices in S that are outside polygon 1 or 2
% ********************************************************** %
A = size(poly1_x,1);
B = size(poly2_x,1);
num = A + B + 1;
poly1_x_temp = poly1_x;
poly1_y_temp = poly1_y;
poly2_x_temp = poly2_x;
poly2_y_temp = poly2_y;
while num == A + B + 1 % 若两个多边形交集为零，则同时扩大这两个多边形
    poly1_x = poly1_x_temp;
    poly1_y = poly1_y_temp;
    poly2_x = poly2_x_temp;
    poly2_y = poly2_y_temp;
    S(:,1) = [poly1_x;poly2_x];
    S(:,2) = [poly1_y;poly2_y];
    for i = 1:size(poly1_x,1)-1
        for j =1:size(poly2_x,1)-1
            
            X1 = [poly1_x(i);poly1_x(i+1)];
            Y1 = [poly1_y(i);poly1_y(i+1)];
            X2 = [poly2_x(j);poly2_x(j+1)];
            Y2 = [poly2_y(j);poly2_y(j+1)];
            [intspoint_x,intspoint_y] = polyxpoly(X1,Y1,X2,Y2); % 求两条线段交点的x,y坐标
            if X1 == X2
                intspoint_x = X1(1);
                intspoint_y = (Y1(1)+Y1(2)+Y2(1)+Y2(2))/4;
            elseif Y1 == Y2
                intspoint_y = Y1(1);
                intspoint_x = (X1(1)+X1(2)+X2(1)+X2(2))/4;
            end
            if ~isempty(intspoint_x) % 若两条线段无交点则跳至下一组线段，若有交点则将交点的x,y坐标存至S中
                S(num,1) = intspoint_x; 
                S(num,2) = intspoint_y;
                num = num+1;
            end
            
        end
    end
    [poly1_x_temp,poly1_y_temp] = polyexpand(poly1_x,poly1_y); % 扩大多边形
    [poly2_x_temp,poly2_y_temp] = polyexpand(poly2_x,poly2_y);
end

IN = inpolygon(S(:,1),S(:,2),poly1_x,poly1_y);
S(IN == 0,:) = [];
IN = inpolygon(S(:,1),S(:,2),poly2_x,poly2_y);
S(IN == 0,:) = [];
X = S(:,1);
Y = S(:,2);
k = convhull(X,Y);
ints_x = X(k);
ints_y = Y(k);