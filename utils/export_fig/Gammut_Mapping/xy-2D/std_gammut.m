function [vert_x,vert_y] = std_gammut
load F:\Dropbox\Works\Matlab»·¾³\Gammut_Mapping\cie1931xyz.txt;
for wl = 380:780
    X = wl*cie1931xyz(wl-379,1);
    Y = wl*cie1931xyz(wl-379,2);
    Z = wl*cie1931xyz(wl-379,3);
    vert_x(wl-379) = X./(X+Y+Z);
    vert_y(wl-379) = Y./(X+Y+Z);
end