function [ints_x,ints_y] = Multipolyints(polygon)
if ~strcmp(class(polygon),'cell') % 检查输入是否为元胞数组
    error('The input must be a cell.');
end
while length(polygon)>1
    for i = 1:floor(length(polygon)/2)
        [ints_x,ints_y] = polygon_intersect(polygon{i}(:,1),polygon{i}(:,2),polygon{end}(:,1),polygon{end}(:,2));
        polygon{i} = [ints_x,ints_y];
        polygon(end) = [];
    end
end
ints_x = polygon{1}(:,1);
ints_y = polygon{1}(:,2);
% function [ints_x,ints_y] = Multipolyints(polygon)
% if ~strcmp(class(polygon),'cell') % 检查输入是否为元胞数组
%     error('The input must be a cell.');
% end
% polygon1 = polygon{1};
% for i = 2:length(polygon) % 循环调用 polygon_intersect 函数
%     polygon2 = polygon{i};
%     [ints_x,ints_y] = polygon_intersect(polygon1(:,1),polygon1(:,2),polygon2(:,1),polygon2(:,2));
%     polygon1 = [ints_x,ints_y];
% end