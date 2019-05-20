function [img_cali,r_gain,g_gain,b_gain,intersection_vertices] = gammutcali(img)
if ~strcmp(class(img),'double')
    img = im2double(img);
end

img_vert_set = img_vert(img);
% trisurf(K,img_vert_set(:,1),img_vert_set(:,2),img_vert_set(:,3),'facecolor',[.5 .9 .85],'facealpha',.5);

intersection_vertices = mapping(img_vert_set);
intersection_vertices_temp = intersection_vertices(:,1)+intersection_vertices(:,2)+intersection_vertices(:,3);
[~,num] = max(intersection_vertices_temp);
r_gain = intersection_vertices(num,1);
g_gain = intersection_vertices(num,2);
b_gain = intersection_vertices(num,3);
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
R = R*r_gain/g_gain;

B = B*b_gain/g_gain;
img_cali = cat(3,R,G,B);
% 
% img_cali = round(img_cali*100)/100;
% r_cali = img_cali(:,:,1);
% g_cali = img_cali(:,:,2);
% b_cali = img_cali(:,:,3);
% r_cali = r_cali(:);
% g_cali = g_cali(:);
% b_cali = b_cali(:);
% point_set = [r_cali,g_cali,b_cali];
% point_set = unique(point_set,'rows');
% k_cali = convhulln(point_set);
% k_cali = k_cali(:);
% k_cali = unique(k_cali);
% vert_set = point_set(k_cali,:);
% K_cali = convhulln(vert_set);
% hold on;trisurf(K_cali,vert_set(:,1),vert_set(:,2),vert_set(:,3),'facecolor',[.9 .5 .6],'facealpha',.5);
