clear; close all; clc;

algorithms = {'gray_world',...
              'max_rgb' ,...
              'shade_of_gray' ,...
              'gray_edge_order1',...
              'gray_edge_order2',...
              'weng'};

config = parse_data_config;

database_dir = fullfile(config.data_path,...
                        'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\*.png');
database = dir(database_dir);

% prepare a record txt file for each algorithm
result_dir = fullfile(config.data_path,...
                      'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\results\comparisons');
if ~exist(result_dir, 'dir')                   
    mkdir(result_dir);
end
for k = 1:numel(algorithms)
    record_dirs{k} = fullfile(result_dir, [algorithms{k}, '_results.txt']);
    if ~exist(record_dirs{k}, 'file')                   
        fid = fopen(record_dirs{k}, 'a');
        fprintf(fid, 'file name\t\testimated rgb\t\tground-truth rgb\t\tangular error\n');
        fclose(fid);
    end
end

errors = zeros(numel(database), numel(algorithms));

for i = 1:numel(database)
    img_dir = fullfile(database(i).folder, database(i).name);
    [~, img_name, ~] = fileparts(img_dir);
    
    fprintf('Processing %s (%d/%d)... ', img_name, i, numel(database));
    tic;
    
    mask_dir = strrep(img_dir, '.png', '_mask.txt');
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    
    img = double(imread(img_dir)) / (2^16 - 1);
    mask = dlmread(mask_dir);
    rgb = dlmread(rgb_dir);
    
    img = mask_img(img, mask);
    illuminant_rgb = get_illuminant_rgb(rgb);
    
    gains = awb_bundle(img);
    
    errors(i, :) = cellfun(@(x)angular_err(illuminant_rgb, 1./gains.(x)), algorithms)';
    
    for k = 1:numel(algorithms)
        fid = fopen(record_dirs{k}, 'a');
        s = sprintf(['%s\t\t',...
                     '%.3f %.3f %.3f\t\t',...
                     '%.3f %.3f %.3f\t\t',...
                     '%.3f\n'],...
                    img_name,...
                    1./(gains.(algorithms{k})),...
                    illuminant_rgb,...
                    errors(i, k));
        fprintf(fid, s);
        fclose(fid);
    end
    
    t = toc;
    fprintf('done. (%.3fs elapsed)\n', t);
    
end

for k = 1:numel(algorithms)
    fid = fopen(record_dirs{k}, 'a');
    fprintf(fid, [repmat('=', 1, 72), '\n']);
    s = sprintf(['mean: %.3f\t\t',...
                 'median: %.3f\t\t',...
                 'Tri: %.3f\t\t',...
                 'best 25%%%%: %.3f\t\t',...
                 'worst 25%%%%: %.3f\n'],...
                mean(errors(:, k)),...
                median(errors(:, k)),...
                trimean(errors(:, k)),...
                best25(errors(:, k)),...
                worst25(errors(:, k)));
    fprintf(fid, s);
    fclose(fid);
end


% ==============================================


function err = angular_err(vec1, vec2)
% angular error in degree
err = 180 * acos(1 - pdist([vec1; vec2], 'cosine')) / pi;
end


function img = mask_img(img, mask_vertices)
[height, width, ~] = size(img);
mask = ~poly2mask(mask_vertices(:, 1), mask_vertices(:, 2), height, width);
img = img .* mask;
end


function y = trimean(x)
assert(isvector(x));
y = (prctile(x, 25) + 2*prctile(x, 50) + prctile(x, 75)) / 4;
end


function y = best25(x)
assert(isvector(x));
x = x(x <= prctile(x, 25));
y = mean(x);
end


function y = worst25(x)
assert(isvector(x));
x = x(x >= prctile(x, 75));
y = mean(x);
end