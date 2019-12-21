function data_config = parse_data_config
% PARSE_DATA_CONFIG returns the root path of data.
% Rewrite .\config\data.conf if you moved the data to another directory.

fid = fopen('data.conf');
if fid == -1
    error('configuration file (data.conf) is not found.');
end

while ~feof(fid)
    line = fgetl(fid);
    if ~startsWith(line, '#')
        s = strsplit(strrep(line, ' ', ''), '=');
        if strcmpi(s{1}, 'root_path')
            data_config.path = s{2};
            break;
        end
    end
end

fclose(fid);