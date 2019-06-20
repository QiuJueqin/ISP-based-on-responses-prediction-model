function xyz_c = cat02(xyz, xyz_white, xyz_reference, LA, F)

if nargin < 6
    F = 1;
end

assert(size(xyz, 2) == 3);
if iscolumn(xyz_white)
    xyz_white = xyz_white';
end
if iscolumn(xyz_reference)
    xyz_reference = xyz_reference';
end

% conversion from CIE tristimulus values (scaled approximately between 0
% and 100, rather than 0 and 1.0) to CAT02 specified RGB responses
matrix_cat02 = [0.7328 0.4296 -0.1624; -0.7036 1.6975 0.0061; 0.0030 0.0136 0.9834];

% step 1
rgb = (matrix_cat02 * xyz')'; % RGB values of CAT02 specification
rgb_white = (matrix_cat02 * xyz_white')';
rgb_reference = (matrix_cat02 * xyz_reference')';

% step 2
D = F * (1 - (1/3.6)*exp((-LA-42)/92));
D = max(min(D, 1), 0);

% step 3
dr = (xyz_white(2) * rgb_reference(1) / rgb_white(1) / xyz_reference(2)) * D + 1 - D;
dg = (xyz_white(2) * rgb_reference(2) / rgb_white(2) / xyz_reference(2)) * D + 1 - D;
db = (xyz_white(2) * rgb_reference(3) / rgb_white(3) / xyz_reference(2)) * D + 1 - D;
rgb_c = rgb .* [dr, dg, db];

% step 4
xyz_c = (matrix_cat02^(-1) * rgb_c')';
