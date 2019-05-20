function extract_spectra(responses_dir)
% EXTRACT_SPECTRA reads corresponding spectral radiance data for the given
% .mat responses file.
%
% INPUTS:
% responses_dir:    directory of .mat responses file, e.g.,
%                   'c:\foo\ISO100_EXP8_A_DSG.mat'.
%
% OUTPUTS:
% None (the extracted spectral radiance data will be saved into original
% .mat files and the new .mat will override the old one).

SPECTRA_DIFF_THRESHOLD = 1E-3;
DELTA_LAMBDA = 5; % 5nm

[folder, responses_name, ext] = fileparts(responses_dir);
assert(strcmp(ext, '.mat'));

res = load(responses_dir); % variable name: 'result'

name = regexp(responses_name, 'ISO(\d+)_EXP(\d+)_(\w+)_(\w+)', 'tokens');
illuminant = name{1}{3};
cc = name{1}{4};

csv_name = strjoin({illuminant, cc}, '_');
csv_dir = fullfile(folder, [csv_name, '.csv']);

if strcmpi(cc, 'dsg')
    csv_range = 'AK15:PU206';
elseif strcmpi(cc, 'classic')
    csv_range = 'AK15:PU62';
end
spectra = xlsread(csv_dir, 1, csv_range); % spectral radiance data
assert(size(spectra, 1) == 2*numel(res.result.responses_flags));

% interpolation
wavelengths = 380:780;
wavelengths_interp = 380:DELTA_LAMBDA:780;
spectra = interp1(wavelengths, spectra', wavelengths_interp, 'pchip')';

% For each color sample, I measured its spectral radiance twice using
% Konica Minolta CS-2000 Spectroradiometer
spectra0 = spectra(1:2:end, :);
spectra1 = spectra(2:2:end, :);

% assert(~isfield(res.result, 'spectra'));

res.result.spectra = (spectra0 + spectra1) / 2;

spectra_flags = ones(numel(res.result.responses_flags), 1);
for i = 1:numel(res.result.responses_flags)
    % area difference
    diff = abs(sum(spectra0(i, :)) - sum(spectra1(i, :))) / (sum(spectra0(i, :)) + sum(spectra1(i, :)));
    % If spectral radiances from two measurements are distinctly different,
    % set this color sample as invalid.
    if diff > SPECTRA_DIFF_THRESHOLD
        spectra_flags(i) = 0;
    end
end

% override the .mat file
result = res.result;
result.spectra_flags = spectra_flags;
save(responses_dir, 'result');
