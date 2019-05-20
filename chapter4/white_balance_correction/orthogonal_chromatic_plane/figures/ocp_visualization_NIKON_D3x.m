clear; close all; clc;

DELTA_LAMBDA = 5;
GAINS = [0.3535, 0.1621, 0.3489]; % ISO100
T = 0.01; % 10ms
WAVELENGTHS = 380:DELTA_LAMBDA:780;
NB_TEMPERATURES = 50;
RED = [255, 84, 84]/255;
BLUE = [0, 128, 220]/255;

data_path = load('global_data_path.mat');

% load parameters of imaging simulation model
params_dir = fullfile(data_path.path,...
                      'imaging_simulation_model\parameters_estimation\responses\NIKON_D3x\camera_parameters.mat');
params = load(params_dir);


%% black bodies

temperatures = 1 ./ linspace(1/3200, 1/12000, NB_TEMPERATURES);
spectra_bb = zeros(NB_TEMPERATURES, numel(WAVELENGTHS));

for i = 1:NB_TEMPERATURES
    t = temperatures(i);
    tmp = BlackBody(t, WAVELENGTHS/1E3);
    % normalization
    XYZ_ = spectra2colors(tmp.SpectralRadiance, WAVELENGTHS);
    spectra_bb(i, :) = tmp.SpectralRadiance/XYZ_(2);
end

% responses prediction for black bodies from 3200K to 12000K
responses_bb = responses_predict(spectra_bb/2, WAVELENGTHS, params.params, GAINS, T, DELTA_LAMBDA);


%% iso-temperature illuminants

spectra_duv = load('SPD_6500K_duv.mat');
spectra_duv = spectra_duv.SPD_6500K_duv(2:end, :)';
XYZ_ = spectra2colors(spectra_duv, WAVELENGTHS);
spectra_duv = spectra_duv ./ XYZ_(:, 2);

% responses prediction for iso-temperature illuminants
responses_duv = responses_predict(spectra_duv/2, WAVELENGTHS, params.params, GAINS, T, DELTA_LAMBDA);

%% visualization

ocp_params_dir = fullfile(data_path.path,...
                          'white_balance_correction\neutral_point_statistics\NIKON_D3x\ocp_params.mat');
load(ocp_params_dir);

% logarithmic plane
ocp_params_log.w = [1/3; 1/3; 1/3];
ocp_params_log.xy0 = [0, 0];
ocp_params_log.theta = 0;
ocp_params_log.sigma = 0;

xtick = -2:0.2:-1;
ytick = -1.8:0.2:-0.6;

xy_log_bb = rgb2ocp(responses_bb, ocp_params_log, 'reverse_y', false);
ocp_diagram_log = ocp_colorize(ocp_params_log,...
                               [xtick(1), xtick(end)],...
                               [ytick(1), ytick(end)],...
                               512,...
                               [],...
                                'reverse_y', false);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
image([xtick(1), xtick(end)], [ytick(1), ytick(end)], flipud(ocp_diagram_log));

grid on; hold on;

scatter(xy_log_bb(:, 1), xy_log_bb(:, 2),...
        48, RED, 'linewidth', 2);
set_axis('$X$', '$Y$', xtick, ytick);
text([xy_log_bb(1,1)-0.04; xy_log_bb(end,1)-0.08],...
     [xy_log_bb(1,2)-0.08; xy_log_bb(end,2)+0.08],...
     {'3000K', '12000K'},...
     'fontname', 'times new roman', 'fontsize', 22,...
     'horizontalalignment', 'left', 'interpreter', 'latex');

% rotated plane
ocp_params_rot = ocp_params;
ocp_params_rot.sigma = 0;

xtick = -0.6:0.3:1.2;
ytick = -0.4:0.2:0.6;

xy_rot_bb = rgb2ocp(responses_bb, ocp_params_rot);
ocp_diagram_rot = ocp_colorize(ocp_params_rot,...
                               [xtick(1), xtick(end)],...
                               [ytick(1), ytick(end)],...
                               512);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
image([xtick(1), xtick(end)], [ytick(1), ytick(end)], flipud(ocp_diagram_rot));

grid on; hold on;

scatter(xy_rot_bb(:, 1), xy_rot_bb(:, 2),...
        48, RED, 'linewidth', 2);
set_axis('$X_{rot}$', '$Y_{rot}$', xtick, ytick);
text([xy_rot_bb(1,1)-0.07; xy_rot_bb(end,1)-0.15],...
     [xy_rot_bb(1,2)+0.05; xy_rot_bb(end,2)+0.05],...
     {'3000K', '12000K'},...
     'fontname', 'times new roman', 'fontsize', 22,...
     'horizontalalignment', 'left', 'interpreter', 'latex');
 
% before shearing
xy_rot_duv = rgb2ocp(responses_duv, ocp_params_rot);

figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
image([xtick(1), xtick(end)], [ytick(1), ytick(end)], flipud(ocp_diagram_rot));

grid on; hold on;

scatter(xy_rot_bb(:, 1), xy_rot_bb(:, 2),...
        48, RED, 'linewidth', 2);
scatter(xy_rot_duv(:, 1), xy_rot_duv(:, 2),...
        48, BLUE, 'linewidth', 2);
set_axis('$X_{rot}$', '$Y_{rot}$', xtick, ytick);
text([xy_rot_bb(1,1)-0.07; xy_rot_bb(end,1)-0.15; xy_rot_duv(1,1)+0.03; xy_rot_duv(end,1)+0.03],...
     [xy_rot_bb(1,2)+0.05; xy_rot_bb(end,2)+0.05; xy_rot_duv(1,2)-0.01; xy_rot_duv(end,2)+0.01],...
     {'3000K', '12000K', '$Duv=-0.02$', '$Duv=0.02$'},...
     'fontname', 'times new roman', 'fontsize', 22,...
     'horizontalalignment', 'left', 'interpreter', 'latex');
 
legend({'Black Body', 'LED D65 Simulator'},...
       'fontname', 'times new roman', 'fontsize', 22, 'box', 'off');
   
% after shearing
xy_orth_bb = rgb2ocp(responses_bb, ocp_params);
xy_orth_duv = rgb2ocp(responses_duv, ocp_params);
ocp_diagram_orth = ocp_colorize(ocp_params,...
                                [xtick(1), xtick(end)],...
                                [ytick(1), ytick(end)],...
                                512);
                            
figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
image([xtick(1), xtick(end)], [ytick(1), ytick(end)], flipud(ocp_diagram_orth));

grid on; hold on;

scatter(xy_orth_bb(:, 1), xy_orth_bb(:, 2),...
        48, RED, 'linewidth', 2);
scatter(xy_orth_duv(:, 1), xy_orth_duv(:, 2),...
        48, BLUE, 'linewidth', 2);
set_axis('$X_{orth}$', '$Y_{orth}$', xtick, ytick);
text([xy_orth_bb(1,1)-0.07; xy_orth_bb(end,1)-0.15; xy_orth_duv(1,1)+0.03; xy_orth_duv(end,1)+0.03],...
     [xy_orth_bb(1,2)+0.05; xy_orth_bb(end,2)+0.05; xy_orth_duv(1,2)-0.01; xy_orth_duv(end,2)+0.01],...
     {'3000K', '12000K', '$Duv=-0.02$', '$Duv=0.02$'},...
     'fontname', 'times new roman', 'fontsize', 22,...
     'horizontalalignment', 'left', 'interpreter', 'latex');

legend({'Black Body', 'LED D65 Simulator'},...
       'fontname', 'times new roman', 'fontsize', 22, 'box', 'off');
 
function set_axis(x_label, y_label, x_tick, y_tick)
grid on; box on;
set(gca, 'ydir', 'normal');

xlim([x_tick(1), x_tick(end)]);
ylim([y_tick(1), y_tick(end)]);

xlabel(x_label, 'fontsize', 26, 'fontname', 'times new roman', 'interpreter', 'latex');
ylabel(y_label, 'fontsize', 26, 'fontname', 'times new roman', 'interpreter', 'latex');

set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 22,...
         'xtick', x_tick, 'ytick', y_tick, 'ticklength', [0, 0]);
end