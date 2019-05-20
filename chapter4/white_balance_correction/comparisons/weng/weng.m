function gains = weng(img)
% modified from 
% https://www.mathworks.com/matlabcentral/fileexchange/14294-program-color-balancing

assert(max(img(:)) <= 1);
std_illuminant_rgb = [0.4207, 1, 0.7713]; % only for Nikon D3x
gains0 = 1 ./ std_illuminant_rgb;
img = img .* reshape(gains0, 1, 1, 3);
img = max(min(img, 1), 0);

im1=rgb2ycbcr(img);
Lu=im1(:,:,1);
Cb=im1(:,:,2);
Cr=im1(:,:,3);
[x, y, ~]=size(img);
tst=zeros(x,y);
Mb=sum(sum(Cb));
Mr=sum(sum(Cr));
Mb=Mb/(x*y);
Mr=Mr/(x*y);
Db=sum(sum(Cb-Mb))/(x*y);
Dr=sum(sum(Cr-Mr))/(x*y);
cnt=1;
Ciny = zeros(1,x*y); %
for i=1:x
    for j=1:y
        b1=Cb(i,j)-(Mb+Db*sign(Mb));
        b2=Cr(i,j)-(1.5*Mr+Dr*sign(Mr));
        if (b1<(1.5*Db) & b2<(1.5*Dr))
            Ciny(cnt)=Lu(i,j);
            tst(i,j)=Lu(i,j);
            cnt=cnt+1;
        end
    end
end
Ciny(cnt:end) = []; %
cnt=cnt-1;
iy=sort(Ciny,'descend');
nn=round(cnt/10);
Ciny2(1:nn)=iy(1:nn);
mn=min(Ciny2);
c=0;
for i=1:x
    for j=1:y
        if tst(i,j)<mn
            tst(i,j)=0;
        else
            tst(i,j)=1;
            c=c+1;
        end
    end
end
R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);
R=double(R).*tst;
G=double(G).*tst;
B=double(B).*tst;
Rav=mean(mean(R));
Gav=mean(mean(G));
Bav=mean(mean(B));
Ymax=double(max(max(Lu)))/15;
Rgain=Ymax/Rav;
Ggain=Ymax/Gav;
Bgain=Ymax/Bav;
gains = [Rgain, Ggain, Bgain] .* gains0;
gains = gains / min(gains);