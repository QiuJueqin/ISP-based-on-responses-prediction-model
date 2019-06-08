function img_cc = cc(img, gains, cc_profile)
% color correction for input image according to its white-balance gains
%
% IMPORTANT NOTE:
% Since the color correction matrices were calibrated using LINEAR camera
% responses, the input image IMG must be converted to LINEAR image before
% color correction. Make sure you have run 'img = raw2linear(img);' before
% calling this function.

global rgb2xyz
rgb2xyz = [0.4124564, 0.3575761, 0.1804375;...
           0.2126729, 0.7151522, 0.0721750;...
           0.0193339, 0.1191920, 0.9503041]';
       
if ndims(img) == 3
    [height, width, ~] = size(img);
    responses = reshape(img, [], 3);
else
    responses = img;
end

if iscolumn(gains)
    gains = gains';
end

% use D65 as canonical illuminant
canonical_illuminant_idx = find(strcmpi(cc_profile.training_illuminant_names, 'd65'), 1);
if isempty(canonical_illuminant_idx)
    error('canonical illuminant (D65) is not found.');
end

canonical_illuminant_gain = cc_profile.gains(canonical_illuminant_idx, :);
uv_train = gain2uv(cc_profile.gains, canonical_illuminant_gain);

uv = gain2uv(gains, canonical_illuminant_gain);

distances = sum((uv_train - uv).^2, 2);
[~, illuminant_idx] = min(distances);
matrix = cc_profile.matrices(:, :, illuminant_idx);
fprintf('matrix calibrated under %s is selected.\n',...
        cc_profile.training_illuminant_names{illuminant_idx});

xyz_cc = ccmapply(responses, cc_profile.model, matrix);
xyz2rgb = rgb2xyz ^ (-1);
rgb_cc = xyz_cc * xyz2rgb;
rgb_cc = max(min(rgb_cc, 1), 0);

if ndims(img) == 3
    img_cc = reshape(rgb_cc, height, width, 3);
else
    img_cc = rgb_cc;
end

end


function uv_pred = gain2uv(gains, gains0)
% gains0: gain of reference illuminant
global rgb2xyz

assert(size(gains, 2) == 3);

cam_rgb = gains ./ gains0;
cam_rgb = cam_rgb ./ max(cam_rgb, [], 2);

xyz_pred = cam_rgb * rgb2xyz;
xyz_pred = xyz_pred ./ xyz_pred(:, 2); % normalized such that Y = 1

xy_pred = xyz_pred(:, [1, 2]) ./ sum(xyz_pred, 2);

uv_pred = [4 * xy_pred(:, 1) ./ (-2 * xy_pred(:, 1) + 12 * xy_pred(:, 2) + 3),...
           9 * xy_pred(:, 2) ./ (-2 * xy_pred(:, 1) + 12 * xy_pred(:, 2) + 3)];

end