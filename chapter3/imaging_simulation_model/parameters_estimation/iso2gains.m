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

if iso < min(iso_profile.isos) || iso > max(iso_profile.isos)
    error('the input iso level exceeds the range [ISO%d, ISO%d] recorded in the profile.',...
          min(iso_profile.isos),...
          max(iso_profile.isos));
end

gains = interp1(iso_profile.isos, iso_profile.gains, iso, 'linear');