function img = pgmread(pgm_dir, darkness, bit)
% PGMREAD reads image from a .pgm file.
% This function has only been tested for OmniVision OV8858.

BAYER_PATTERN = 'RGGB'; % for OV8858

if nargin == 1
    darkness = [0.0627, 0.0626, 0.0627];
    bit = 16;
end

darkness = reshape(darkness, 1, 1, 3);

img = imread(pgm_dir);
img = double(demosaic_(img, BAYER_PATTERN))/(2^bit-1) - darkness;
end


function RGB = demosaic_(raw, sensorAlignment)
% DEMOSAIC_ performs demosaicking without interpolation
% 
% MATLAB built-in demosaic function generates a H*W*3 color image from a
% H*W*1 grayscale cfa image by 'guessing' the pixel's RGB values from its
% neighbors, which might introduces some color biases (althout negligible
% for most of applications).
%
% DEMOSAIC_NOINTERP generates a (H/2)*(W/2)*3 color image from the original
% cfa image without interpolation. The G value of each pixel in the output
% color image is produced by averaging two green sensor elements in the
% quadruplet.

switch upper(sensorAlignment)
    case 'RGGB'
        [r_begin, g1_begin, g2_begin, b_begin] = deal([1, 1], [1, 2], [2, 1], [2, 2]);
    case 'BGGR'
        [r_begin, g1_begin, g2_begin, b_begin] = deal([2, 2], [1, 2], [2, 1], [1, 1]);
    case 'GBRG'
        [r_begin, g1_begin, g2_begin, b_begin] = deal([2, 1], [1, 1], [2, 2], [1, 2]);
    case 'GRBG'
        [r_begin, g1_begin, g2_begin, b_begin] = deal([1, 2], [1, 1], [2, 2], [2, 1]);
end
R = raw(r_begin(1):2:end, r_begin(2):2:end);
G1 = raw(g1_begin(1):2:end, g1_begin(2):2:end);
G2 = raw(g2_begin(1):2:end, g2_begin(2):2:end);
B = raw(b_begin(1):2:end, b_begin(2):2:end);
G = cast((double(G1) + double(G2))/2, 'like', G1);  % to avoid overflow
RGB  = cat(3, R, G, B);
end