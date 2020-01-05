function [post_gains, cct] = catgain(wb_gains, cc_profile, F, LA)
% CATGAINS calculates a set of re-adjustment coefficients (post gains)
% based on CAT02 chromatic adaptation transformation model. The obtained
% coefficients should only be applied to a white-balanced image instead of
% a raw one, or be cooperated with awb gains, i.e.,
% new_gains = post_gains .* gains;

if nargin < 4 || isempty(LA)
    % adapting luminance in cd/m^2, often taken to be 20% of the luminance of a
    % white object in the scene 
    LA = 100; 
end

if nargin < 3 || isempty(F)
    % maximum degree of adaptation
    F = 1; 
end

rgb2xyz = [0.4124564, 0.3575761, 0.1804375;...
           0.2126729, 0.7151522, 0.0721750;...
           0.0193339, 0.1191920, 0.9503041]';

if iscolumn(wb_gains)
    wb_gains = wb_gains';
end

% use D65 as canonical illuminant
canonical_illuminant_idx = find(strcmpi(cc_profile.training_illuminant_names, 'd65'), 1);
if isempty(canonical_illuminant_idx)
    error('canonical illuminant (D65) is not found.');
end
canonical_illuminant_gains = cc_profile.gains(canonical_illuminant_idx, :);
rgb_illuminant = canonical_illuminant_gains ./ wb_gains; % camera rgb of illuminant

xyz_illuminant = rgb_illuminant * rgb2xyz;
xy_illuminant = xyz_illuminant([1, 2]) / sum(xyz_illuminant);
cct = xy2cct(xy_illuminant);

% chromatic adaptation transformation (core of this function)
xyz_illuminant_adapted = cat02(xyz_illuminant, xyz_illuminant, whitepoint('d65'), LA, F);

rgb_illuminant_adapted = xyz_illuminant_adapted * rgb2xyz^(-1);

rgb_canonical_illuminant = whitepoint('d65') * rgb2xyz^(-1);

post_gains = rgb_illuminant_adapted ./ rgb_canonical_illuminant;
post_gains = post_gains / post_gains(2);

end
