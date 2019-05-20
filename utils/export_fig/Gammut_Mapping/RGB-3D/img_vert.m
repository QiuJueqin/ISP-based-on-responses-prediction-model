function vert_set = img_vert(img)
if ~strcmp(class(img),'double')
    img = im2double(img);
end
img = round(img*100)/100;
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
r = r(:);
g = g(:);
b = b(:);
point_set = [r,g,b];
point_set = unique(point_set,'rows');
k = convhulln(point_set);
k = k(:);
k = unique(k);
vert_set = point_set(k,:);

N = 0.005;
for i = 1:size(vert_set,1)-1
    for j = (i+1):size(vert_set,1)
        if (vert_set(i,1)-vert_set(j,1))^2 + (vert_set(i,2)-vert_set(j,2))^2 + (vert_set(i,3)-vert_set(j,3))^2 < N
            vert_set(j,:) = [0,0,0];           
        end
    end
end
vert_set(find((vert_set(:,1)==0)&(vert_set(:,2)==0)&(vert_set(:,3)==0)),:) = [];
% 
% K = convhulln(vert_set);
% hold on;trisurf(K,vert_set(:,1),vert_set(:,2),vert_set(:,3),'facecolor',[.8 .7 .85],'facealpha',.6);
