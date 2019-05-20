function rgb = xy2rgb(xy)
x = xy(:,:,1);
y = xy(:,:,2);
Y = 100;
X = (Y*x)./y;
Z = Y *(1-x-y)./y;
Y = 100*ones(size(x,1),size(x,2));
rgb = xyz2rgb(cat(3,X,Y,Z));