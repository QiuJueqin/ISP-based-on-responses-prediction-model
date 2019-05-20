function sRGB = xyz2srgb(XYZ)
%xyz2srgb Convert sRGB colors to XYZ colors
%
%   srgb = xyz2srgb(xyz) converts a P-by-3 matrix of XYZ colors to a P-by-3
%   matrix of sRGB colors (in the range [0,1]).

%   Copyright 2013 The MathWorks, Inc.

T = [3.2410 -1.5374 -0.4986
    -0.9692 1.8760 0.0416
    0.0556 -0.2040 1.0570];

sRGB = T * XYZ.';

small = sRGB <= 0.00304;
sRGB(small) = sRGB(small) * 12.92;

not_small = ~small;
sRGB(not_small) = 1.055 * sRGB(not_small).^(1.0/2.4) - 0.055;

sRGB = sRGB.';


