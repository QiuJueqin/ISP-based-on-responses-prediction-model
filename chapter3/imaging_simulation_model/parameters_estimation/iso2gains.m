function gains = iso2gains(iso, iso_profile)
% ISO2GAINS calculates system gains (g0) given iso level(s) using linear
% interpolation.
%
% INPUTS:
% iso:            iso levels of the camera, e.g., 100, 125, 160, 200, ...
% iso_profile:    a profile that records system gains of different iso
%                 levels.
%
% OUTPUTS:
% gains:          predicted system gains.

if iso < min(iso_profile.isos) || iso >= max(iso_profile.isos)
    error('The iso levels recorded in the profile are in the range of %d to %d',...
          min(iso_profile.gains),...
          max(iso_profile.gains));
end

gains = interp1(iso_profile.isos, iso_profile.gains, iso, 'linear');