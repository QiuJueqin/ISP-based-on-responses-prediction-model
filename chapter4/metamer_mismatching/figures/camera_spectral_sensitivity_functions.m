clear; close all; clc;

RED = [213 78 68]/255;
GREEN = [123 215 108]/255;
BLUE = [116 171 227]/255;

load('camera_spectra_dataset.mat')

camera_names = {'Canon_60D_DSLR',...
                'Nikon_D80_DSLR',...
                'Point_Grey_Grasshopper-50S5C_Industrial'};


figure('color', 'w', 'unit', 'centimeters', 'position', [2, 5, 48, 12]);

for i = 1:numel(camera_names)
    idx = find(strcmpi(camera_names{i}, {camera_spectra_dataset.camera_model}), 1);
    wavelengths = camera_spectra_dataset(idx).wavelength;
    spectra = camera_spectra_dataset(idx).spectral_sensitivity;
    
    hax = subplot(1, 3, i);
    pos = get(hax, 'OuterPosition');
    pos = pos + [-0.025, 0.02, 0.05, -0.04];
    set(hax, 'OuterPosition', pos);
    
    hold on;
    
    plot(wavelengths, spectra(:,1), 'color', RED, 'linewidth', 3);
    plot(wavelengths, spectra(:,2), 'color', GREEN, 'linewidth', 3);
    plot(wavelengths, spectra(:,3), 'color', BLUE, 'linewidth', 3);
    box on; grid on
    set(gca, 'linewidth', 1.5, 'fontname', 'times new roman', 'fontsize', 22,...
        'xtick', 380:100:780, 'ytick', 0:0.2:1);
    xlim([380, 780]);
    ylim([0, 1.1]);
    xlabel('Wavelength (nm)', 'fontname', 'times new roman', 'fontsize', 28);
    if i == 1
        ylabel('Spectral Sensitivities', 'fontname', 'times new roman', 'fontsize', 28);
    end
end
