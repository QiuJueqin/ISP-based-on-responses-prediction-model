function ocp_params = find_ocp_params(camera_params, gains)
% FIND_OCP_PARAMS finds optimal parameters for constructing orthogonal
% chromatic plane as per Sectionxx in Chapter 4.

T = 0.01; % 10ms exposure time
DELTA_LAMBDA = 5;
WAVELENGTHS = 380:DELTA_LAMBDA:780;
NB_BLACKBODIES = 100;


%% daylight series from 4000K to 12000K

components = xlsread('DaylightSeries.xls', 1, 'N24:P64');
coefs = xlsread('DaylightSeries.xls',1,'I15:J65');
spectra_dl = [ones(length(coefs), 1), coefs] * components';
% interpolation and normalization
spectra_dl = interp1(380:10:780, spectra_dl', WAVELENGTHS, 'pchip')';
XYZ_ = spectra2colors(spectra_dl, WAVELENGTHS);
spectra_dl = spectra_dl ./ XYZ_(:, 2);

% responses prediction for daylight series
responses_dl = responses_predict(spectra_dl/2, WAVELENGTHS, camera_params, gains, T, DELTA_LAMBDA);


%% black bodies from 3200K to 12000K

temperatures = 1 ./ linspace(1/3200, 1/12000, NB_BLACKBODIES);
spectra_bb = zeros(NB_BLACKBODIES, numel(WAVELENGTHS));

for i = 1:NB_BLACKBODIES
    t = temperatures(i);
    tmp = BlackBody(t, WAVELENGTHS/1E3);
    % normalization
    XYZ_ = spectra2colors(tmp.SpectralRadiance, WAVELENGTHS);
    spectra_bb(i, :) = tmp.SpectralRadiance/XYZ_(2);
end

% responses prediction for black bodies
responses_bb = responses_predict(spectra_bb/2, WAVELENGTHS, camera_params, gains, T, DELTA_LAMBDA);


%% find optimal weights and theta

w0 = [1/3; 1/3; 1/3];
xy_dl = [log((w0(1) * responses_dl(:, 1)) ./ (responses_dl * w0)),...
         log((w0(3) * responses_dl(:, 3)) ./ (responses_dl * w0))];
xy_bb = [log((w0(1) * responses_bb(:, 1)) ./ (responses_bb * w0)),...
         log((w0(3) * responses_bb(:, 3)) ./ (responses_bb * w0))];
p_dl = polyfit(xy_dl(:, 1), xy_dl(:, 2), 1);
p_bb = polyfit(xy_bb(:, 1), xy_bb(:, 2), 1);

theta0 = (-atan(p_dl(1)) + -atan(p_bb(1))) / 2;

w_handle = @(x) [x(1); x(2); x(3)];
theta_handle = @(x) x(4);

xy_dl_handle = @(x) [log(([1, 0, 0] * w_handle(x) * responses_dl(:, 1)) ./ (responses_dl * w_handle(x))),...
                     log(([0, 0, 1] * w_handle(x) * responses_dl(:, 3)) ./ (responses_dl * w_handle(x)))];
xy_bb_handle = @(x) [log(([1, 0, 0] * w_handle(x) * responses_bb(:, 1)) ./ (responses_bb * w_handle(x))),...
                     log(([0, 0, 1] * w_handle(x) * responses_bb(:, 3)) ./ (responses_bb * w_handle(x)))];

Z = zeros(1, length(coefs));
Z(26) = 1; % index for D65

xy0_handle = @(x) Z * xy_dl_handle(x);

xy_dl_handle = @(x) xy_dl_handle(x) - xy0_handle(x);
xy_bb_handle = @(x) xy_bb_handle(x) - xy0_handle(x);

% rotation (reverse Y-axis)
mrot_handle = @(x) [cos(theta_handle(x)), -sin(theta_handle(x));...
                    sin(theta_handle(x)),  cos(theta_handle(x))];

xy_dl_rot_handle = @(x) xy_dl_handle(x) * mrot_handle(x)';
xy_bb_rot_handle = @(x) xy_bb_handle(x) * mrot_handle(x)';
loss = @(x) var(xy_dl_rot_handle(x) * [0; 1]) + 0.5*var(xy_bb_rot_handle(x) * [0; 1]);

Aeq = [1, 1, 1, 0];
beq = 1;
lb = [.25; .25; .25; -pi];
ub = [.75; .75; .75; pi];
init = [w0; theta0];

x = fmincon(loss, init, [], [], Aeq, beq, lb, ub);
w = x(1:3);
theta = x(4);
xy0 =  Z * [log((w(1) * responses_dl(:, 1)) ./ (responses_dl * w)),...
            log((w(3) * responses_dl(:, 3)) ./ (responses_dl * w))];


%% find optimal sigma

spectra_duv = load('SPD_6500K_duv.mat');
spectra_duv = spectra_duv.SPD_6500K_duv(2:end, :)';
XYZ_ = spectra2colors(spectra_duv, WAVELENGTHS);
spectra_duv = spectra_duv ./ XYZ_(:, 2);

% responses prediction for iso-temperature illuminants
responses_duv = responses_predict(spectra_duv/2, WAVELENGTHS, camera_params, gains, T, DELTA_LAMBDA);

ocp_params.w = w;
ocp_params.xy0 = xy0;
ocp_params.theta = theta;
ocp_params.sigma = 0;

[~, xy_duv_rot, ~] = rgb2ocp(responses_duv, ocp_params);

% reverse Y-axis so the upper-left element in the shearing matrix is -1
loss = @(sigma) var(xy_duv_rot*[1, sigma; 0, -1]'*[1; 0]);
sigma = fminbnd(loss, -10, 10);

ocp_params.sigma = sigma;

rb_dl = rgb2ocp(responses_dl, ocp_params);
rb_bb = rgb2ocp(responses_bb, ocp_params);
rb_duv = rgb2ocp(responses_duv, ocp_params);

ocp_params.w = w;
ocp_params.xy0 = xy0;
ocp_params.theta = theta;
ocp_params.sigma = sigma;

figure; hold on;
scatter(rb_dl(:, 1), rb_dl(:, 2));
scatter(rb_bb(:, 1), rb_bb(:, 2));
scatter(rb_duv(:, 1), rb_duv(:, 2));
axis equal
