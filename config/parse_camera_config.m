function config = parse_camera_config(camera_name, profile_names)
fid = fopen(sprintf('%s.conf', camera_name));

if fid == -1
    error('no configuration file for camera %s is found.', camera_name);
end

if nargin < 2 || isempty(profile_names)
    profile_names = {'response', 'gains', 'noise', 'color'};
elseif ischar(profile_names)
    profile_names = {profile_names};
end

while ~feof(fid)
    line = fgetl(fid);
    if ~startsWith(line, '#')
        line = strrep(line, ' ', '');
        s = strsplit(line, '=');
        if ismember(s{1}, profile_names)
            key = profile_names{strcmpi(s{1}, profile_names)};
            value = s{2};
            config.(key) = value;
        end
    end
end

fclose(fid);