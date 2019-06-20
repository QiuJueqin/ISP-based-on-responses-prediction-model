function config = parse_data_config
fid = fopen('data.conf');

if fid == -1
    error('no configuration file (data.conf) is found in the accessible paths.');
end

while ~feof(fid)
    line = fgetl(fid);
    if ~startsWith(line, '#')
        s = strsplit(strrep(line, ' ', ''), '=');
        if strcmpi(s{1}, 'data_root_path')
            config.data_path = s{2};
            break;
        end
    end
end

fclose(fid);