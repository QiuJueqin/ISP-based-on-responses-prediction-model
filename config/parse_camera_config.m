function config = parse_camera_config(camera_name, profile_names)
% Load calibration profile(s) for modules.
% See .\config\NIKON_D3x.conf or .\config\SONY_ILCE7.conf for more
% information.
%
% INPUTS:
% profile_names: a cell containing module names to load calibration
%                profiles. ('responses' | 'gains' | 'ocp' | 'standard_gamut' |
%                'color')

fid = fopen(sprintf('%s.conf', camera_name));
if fid == -1
    error('no data_configuration file for camera %s is found.', camera_name);
end

default_profile_names = {'responses', 'gains', 'ocp', 'standard_gamut', 'color'};

if nargin < 2 || isempty(profile_names)
    profile_names = default_profile_names;
elseif ischar(profile_names)
    profile_names = {profile_names};
end
assert(all(ismember(profile_names, default_profile_names)), ...
       'Only following profiles are supported:\n%s',...
       strjoin(default_profile_names, ' | '));

data_config = parse_data_config;

while ~feof(fid)
    line = fgetl(fid);
    if startsWith(line, '#')
        continue;
    end
    line = strrep(line, ' ', '');
    s = strsplit(line, '=');
    if ~ismember(s{1}, profile_names)
        continue;
    end
    key = profile_names{strcmpi(s{1}, profile_names)};
    profile_path = fullfile(data_config.path, s{2});
    profile_path = strrep(profile_path, [filesep, filesep], filesep);
    try
        config.(key) = load(profile_path);
    catch
        warning('%s profile is not found for %s. Check the directory: %s',...
                key, camera_name, profile_path);
    end
end

fclose(fid);
