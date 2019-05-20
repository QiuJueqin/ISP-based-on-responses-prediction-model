function K_estimate = estimate_K(mu_estimate_concat, g0_estimate, mu_dark_estimate)
% ESTIMATE_K calculate fixed pattern noise K(i,j) as per Eq.(49) in
% Chapter 3.
%
% mu_estimate_concat:   concatenated mu_estimate (H*W*3*n5 tensor) returned
%                       by estimate_g0().
% g0_estimate:          estimated g0 returned by estimate_g0().
% mu_dark_estimate:     estimated mu_dark map returned by
%                       Nikon_D3x_mu_dark_estimate().

w2 = 15;

% see Eq.(46)
e_estimate_concat = (mu_estimate_concat - mu_dark_estimate) ./ reshape(g0_estimate, 1, 1, 3); % H*W*3*n5

% see Eq.(47)
kernel = ones(w2, w2) / w2^2;
e_estimate_local_mean_concat = imfilter(e_estimate_concat, kernel, 'circular', 'same', 'conv'); % H*W*3*n5

% % see Eq.(49)
% K_estimate = mean(e_estimate_concat ./ e_estimate_local_mean_concat, 4);

% robust linear regression (very slow)
warning('off','all');

[height, width, ~] = size(e_estimate_concat);
K_estimate = zeros(height, width, 3);

% calculate in parallel
poolobj = parpool;

parfor k = 1:3
    warning('off','all');
    percent = 0;
    for x = 1:width
        for y = 1:height
            X = squeeze(e_estimate_local_mean_concat(y, x, k, :));
            Y = squeeze(e_estimate_concat(y, x, k, :));
            K_estimate(y, x, k) = robustfit(X, Y, [], [], 'off');
        end
        current_percent = floor(100 * x / width);
        if current_percent > percent && k == 3
            percent = current_percent;
            fprintf_r('%d%%\n', current_percent);
        end
    end
end

fprintf_r('\n', [], 'reset');

delete(poolobj);








