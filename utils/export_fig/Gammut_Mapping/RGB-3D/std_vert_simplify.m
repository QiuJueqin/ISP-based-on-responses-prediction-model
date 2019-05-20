load F:\Dropbox\Works\Matlab环境\Gammut_Mapping\RGB-3D\vert_set.mat
N = 0.1;
for i = 1:size(vert_set,1)-1
    for j = (i+1):size(vert_set,1)
        if (vert_set(i,1)-vert_set(j,1))^2 + (vert_set(i,2)-vert_set(j,2))^2 + (vert_set(i,3)-vert_set(j,3))^2 < N
            vert_set(j,:) = [0,0,0];
            
        end
    end
end
vert_set(find((vert_set(:,1)==0)&(vert_set(:,2)==0)&(vert_set(:,3)==0)),:) = []
save F:\Dropbox\Works\Matlab环境\Gammut_Mapping\RGB-3D\vert_set_1.mat vert_set