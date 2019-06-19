clear; close all; clc;

GAP = 0.032;
MATRIX = getcam2xyz('Nikon D3x');

config = parse_data_config;

algorithms = {'gray_edge_order1',...
              'gray_edge_order2',...
              'gray_world',...
              'shade_of_gray',...
              'weng',...
              'gmap_npstat'};

image_names = {'DSC_2368', ...
               'DSC_2838', ...
               'DSC_2830', ...
               'DSC_2349', ...
               'DSC_2432'};
scales = [3.2, 2.5, 3, 2.2, 2];

height = (1 - GAP * (numel(algorithms) + 1)) / (numel(algorithms) + 1);

record_folder = fullfile(config.data_path,...
                        'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\results\comparisons');
record_dirs = fullfile(record_folder, strcat(algorithms, '_results.txt'));
for i = 1:numel(image_names)
    img_name = image_names{i};
    img_dir = fullfile(config.data_path, 'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset', [img_name, '.png']);
    img = imread(img_dir);
    img = imresize(img, 1/4);
    
    figure('color', 'w', 'unit', 'centimeters', 'position', [10, 1, 7, 30], 'menu', 'none');
    
    % show ground-truth image
	[~, ground_truth, ~] = read_date(record_dirs{1}, img_name);
    gains = 1 ./ ground_truth;

    output = matrawproc(img, 'wb', gains / min(gains), 'cam2xyz', MATRIX);
    output = max(min(output * scales(i), 1), 0) .^ (1/2.2);

    ax = subplot('position', [0.1,...
                              1 - 0.4*GAP - height,...
                              0.8,...
                              height]);
    imshow(output);
        
    for k = 1:numel(algorithms)
        [estimate, ~, error.(algorithms{k})(i)] = read_date(record_dirs{k}, img_name);
        
        gains = 1 ./ estimate;
        
        output = matrawproc(img, 'wb', gains / min(gains), 'cam2xyz', MATRIX);
        output = max(min(output * scales(i), 1), 0) .^ (1/2.2);

        ax = subplot('position', [0.1,...
                                  1 - k*GAP - (k+1)*height,...
                                  0.8,...
                                  height]);
        imshow(output);
        
        text(ax, 0.5, -0.14, sprintf('$\\ \\ %.2f^\\circ$', error.(algorithms{k})(i)),...
             'units', 'normalized', 'fontname', 'times new roman', 'fontsize', 16,...
             'horizontalalignment', 'center', 'interpreter', 'latex');
    end
    
end

function [estimate, groundtruth, error] = read_date(txt_dir, img_name)
fid = fopen(txt_dir);
while ~feof(fid)
    tline = fgetl(fid);
    if contains(tline, img_name)
        s = strsplit(tline, '\t\t');
        estimate = str2num(s{2});
        groundtruth = str2num(s{3});
        error = str2num(s{4});
    end
end
fclose(fid);
end
