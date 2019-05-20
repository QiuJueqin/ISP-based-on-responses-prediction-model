function vertices = standard_gamut_calib(camera_params, gains, spectral_reflectances_database, std_illuminant_spd)
% INPUTS:
% camera_params:                    parameters of imaging simulation model.
% gains:                            1x3 system gains (g0).
% spectral_reflectances_database:   N*M spectral reflectance data where N
%                                   is the number of samples an M is the
%                                   number of wavelengths. (default = our
%                                   reflectance dataset containing 9270
%                                   data)
% std_illuminant_spd:               1*M spectral power distribution of the
%                                   standard illuminant. (default = D65)

T = 0.01; % 10ms exposure time
DELTA_LAMBDA = 5;
WAVELENGTHS = 380:DELTA_LAMBDA:780;
MIN_ENERGY_THRESHOLD = 0.02;
DARKNESS_THRESHOLD = 0.01;
AUGMENT_CENTER = [1.5, 1];
AUGMENT_RATIO = 0.05;

if nargin <= 3
    std_illuminant_spd = xlsread('cie.15.2004.tables.xls',1,'C23:C103')';
end
if nargin <= 2
    spectral_reflectances_database = xlsread('spectral_reflectances_database.xlsx', 1, 'D3:CF9272');
end

assert(size(spectral_reflectances_database, 2) == numel(WAVELENGTHS));
assert(isrow(std_illuminant_spd) && numel(std_illuminant_spd) == numel(WAVELENGTHS));

% use cie y values as energies and remove those samples with lowest energies
xyz = spectra2colors(spectral_reflectances_database, 380:5:780, 'spd', 'd65');
spectral_reflectances_database(xyz(:, 2) < MIN_ENERGY_THRESHOLD, :) = [];

spectra = std_illuminant_spd .* spectral_reflectances_database;

[~, saturation] = responses_predict(spectra, WAVELENGTHS, camera_params, gains, T, DELTA_LAMBDA);
responses = responses_predict(spectra/saturation, WAVELENGTHS, camera_params, gains, T, DELTA_LAMBDA);

darkness_pix_indices = any(responses < DARKNESS_THRESHOLD, 2);
responses(darkness_pix_indices, :) = [];

% in [r/g, b/g] plane
rb = responses(:, [1, 3]) ./ responses(:, 2);

vertices = rb(convhull(rb), :);

hfig = figure('color', 'w', 'unit', 'centimeters', 'position', [5, 5, 24, 16]);
hold on;
line(vertices(:, 1), vertices(:, 2));

xlim([0, 1.5*max(vertices(:, 1))]);
ylim([0, 1.5*max(vertices(:, 2))]);

xlabel('r/g');
ylabel('b/g');

vertices = poly_augment(vertices, AUGMENT_CENTER, AUGMENT_RATIO);
line(vertices(:, 1), vertices(:, 2), 'linestyle', '--');

% allow manual adjustment
hpoly = drawpolygon('position', vertices);
uicontrol(hfig,...
          'string', 'continue',...
          'callback', @pushbutton_callback);
uiwait(hfig);

vertices = hpoly.Position;

if ~isequal(vertices(1, :), vertices(end, :))
    vertices = [vertices; vertices(1, :)];
end

line(vertices(:, 1), vertices(:, 2), 'color', 'k', 'linewidth', 2);

end


function pushbutton_callback(hObject, eventdata, handles)
%%
% callback function of the figure
uiresume;
set(hObject, 'visible', 'off');
end
