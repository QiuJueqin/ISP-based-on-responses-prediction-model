clear; close all; clc;

STD_ILLUMINANT_RGB = [0.4207, 1, 0.7713]; % only for Nikon D3x
NEUTRAL_REGION0 = [-0.3,  0.05;...
                    0,    0.15;...
                    0.6,  0.15;...
                    0.8,  0.05;...
                    0.8, -0.05;...
                   -0.3, -0.05;...
                   -0.3,  0.05];
XLIM = [-0.6, 1.2];
YLIM = [-0.4, 0.6];
GRID_SIZE = 128;

data_path = load('global_data_path.mat');

% load ocp parameters
ocp_params_dir = fullfile(data_path.path,...
                          'white_balance_correction\neutral_point_statistics\NIKON_D3x\ocp_params.mat');
load(ocp_params_dir);

% load standard gamut
std_gamut_dir = fullfile(data_path.path,...
                         'white_balance_correction\gamut_mapping\NIKON_D3x\std_gamut.mat');
load(std_gamut_dir);

result_dir = fullfile(data_path.path,...
                       'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\results');
if ~exist(result_dir, 'dir')                   
    mkdir(result_dir);
end
record_dir = fullfile(result_dir, 'results.txt');
if ~exist(record_dir, 'file')                   
    fid = fopen(record_dir, 'a');
    fprintf(fid, 'file name\t\testimated rgb\t\tground-truth rgb\t\tangular error\n');
    fclose(fid);
end

% read test images
dataset_dir = fullfile(data_path.path,...
                        'white_balance_correction\neutral_point_statistics\NIKON_D3x\colorchecker_dataset\*.png');
dataset = dir(dataset_dir);

errors = zeros(numel(dataset), 1);

for i = 1:numel(dataset)
    img_dir = fullfile(dataset(i).folder, dataset(i).name);
    [~, img_name, ~] = fileparts(img_dir);
    
    fprintf('Processing %s (%d/%d)... ', img_name, i, numel(dataset));
    tic;
    
    mask_dir = strrep(img_dir, '.png', '_mask.txt');
    rgb_dir = strrep(img_dir, '.png', '_rgb.txt'); % ground-truth
    
    img = double(imread(img_dir)) / (2^16 - 1);
    mask = dlmread(mask_dir);
    rgb = dlmread(rgb_dir);
    
    illuminant_rgb = get_illuminant_rgb(rgb);
    illuminant_xy_orth = rgb2ocp(illuminant_rgb, ocp_params);
    
    [~, gains] = awb(img,...
                     ocp_params, NEUTRAL_REGION0, std_gamut, STD_ILLUMINANT_RGB,...
                     XLIM, YLIM, GRID_SIZE,...
                     mask);
                 
	pause(.5);

 	save_fig(illuminant_xy_orth, result_dir, img_name);
    
    errors(i) = angular_err(illuminant_rgb, 1./gains);
    
    fid = fopen(record_dir, 'a');
    s = sprintf(['%s\t\t',...
                 '%.3f %.3f %.3f\t\t',...
                 '%.3f %.3f %.3f\t\t',...
                 '%.3f\n'],...
                img_name, 1./gains, illuminant_rgb, errors(i));
    fprintf(fid, s);
    fclose(fid);
    
    t = toc;
    fprintf('done. (%.3fs elapsed)\n', t);
    
end

fid = fopen(record_dir, 'a');
fprintf(fid, [repmat('=', 1, 72), '\n']);
s = sprintf(['mean: %.3f\t\t',...
             'median: %.3f\t\t',...
             'tri: %.3f\t\t',...
             'best 25%%%%: %.3f\t\t',...
             'worst 25%%%%: %.3f\n'],...
            mean(errors),...
            median(errors),...
            trimean(errors),...
            best25(errors),...
            worst25(errors));
fprintf(fid, s);
fclose(fid);


% ==============================================

function illuminant_rgb = get_illuminant_rgb(rgb)
DARKNESS_THRESHOLD = 0.05;
SATURATION_THRESHOLD = 0.9;

assert(isequal(size(rgb), [24, 3]));

idx = 20;
illuminant_rgb = rgb(idx, :);

if min(illuminant_rgb) < DARKNESS_THRESHOLD
    illuminant_rgb = rgb(19, :);
end

while max(illuminant_rgb) > SATURATION_THRESHOLD
    idx = idx + 1;
    illuminant_rgb = rgb(idx, :);
end

if idx >= 23
    warning('image is oversaturated.');
end

illuminant_rgb = illuminant_rgb / illuminant_rgb(2);

end


function err = angular_err(vec1, vec2)
% angular error in degree
err = 180 * acos(1 - pdist([vec1; vec2], 'cosine')) / pi;
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


function save_fig(illuminant_xy_orth, save_dir, img_name)
hfigs = get(groot, 'Children');

if numel(hfigs) ~= 2
    warning('figures are not found.');
    return;
end

hfig_hist = hfigs(1);
hfig_gamut = hfigs(2);

hax = get(hfig_gamut, 'children');
scatter(hax, illuminant_xy_orth(1), illuminant_xy_orth(2), 128, 'k', 'filled');

hist_save_dir = fullfile(save_dir, [img_name, '_hist.jpg']);
gamut_save_dir = fullfile(save_dir, [img_name, '_gamut.jpg']);

saveas(hfig_hist, hist_save_dir);
saveas(hfig_gamut, gamut_save_dir);

close(hfig_hist);
close(hfig_gamut);
end