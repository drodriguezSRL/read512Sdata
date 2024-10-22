%{ 
%%%%%%%%%%%%  README  %%%%%%%%%%%%
Original script by David Rodríguez (https://github.com/drodriguezSRL)
Last updated: 2024-Oct-22

Works with data from the following cameras: 
- SwissSPAD2 Top Half array (512x256)
- Pi-Imaging SPAD512S (512x512)

This script builds up and exports a sequence of n-bit frames in PNG format 
captured during a single acquisition. 

"Frame" = 1-bit image
"Image" = n-bit image

NOTE: 1-bit frames need to be exported first using
- 'export_binaries_ss2TH.m' for data acquired with the SwissSPAD2
- 'export_binaries_512S.m' for data acquired with the SPAD512S
%}
close all; clear all; clc;

%%%%%%%%%%%%  VARIABLES DEFINITION  %%%%%%%%%%%%
file_path='.\noon-off\spad\1.0us'; % change this to your own!
bit_path='/png/1bit/'; % change this to your own!
no_rows=512;
no_cols=512;

% Define desired bit depth 
desired_bitdepth = 8;

%%%%%%%%%%%%  PRELIMINARY CALCULATIONS  %%%%%%%%%%%%
disp("Reading directory...")
directory = fullfile(file_path,bit_path);

if ~exist(directory, 'dir') 
    error('Directory "%s" does not exist. Make sure binary frames have been previously exported to PNG.', content);
end

content = dir(fullfile(directory, '*.png'));
totnum_frames = numel(content);

fprintf('Total number of 1-bit frames: %d\n', totnum_frames);

frames_per_img = 2^desired_bitdepth;
fprintf('Desired bitdept: %d\n', desired_bitdepth)

% Define number of n-bit images to export. Leave 0 for max number of n-bit
% images possible.
num_images = 0; 
if num_images == 0
    num_images = totnum_frames/256;
end
fprintf('Total number of images to digitize: %.2d\n', num_images);


new_Pdir = file_path + "/png/" + string(desired_bitdepth) + "bit/";
if ~exist(new_Pdir, 'dir')
    mkdir(new_Pdir);
end

colormap_nbit = gray(frames_per_img); % Generates a n-level grayscale colormap required for saving n-bit PNGs lower than 8-bit

%%%%%%%%%%%%  EXPORT FRAMES  %%%%%%%%%%%%
% Images will be exported 1 by 1 based at the desired_bitdepth.
% This means that if 8-bit is selected, 256 1-bit frames will be read at a time
f = waitbar(0, "Saving images...");
frame_num = 1;

subarray = zeros(frames_per_img, no_rows, no_cols);
 
for i = 1:num_images
    msg1 = 'Saving image ' + string(i) + '/' + string(num_images);
    waitbar(i/num_images,f,msg1);

    if i == 1
        disp('Estimating total digitization time...')
        tic;
    elseif i == 2
        digitize_time = time1img*num_images;
        dt_hours = floor(digitize_time / 3600);
        dt_rest = mod(digitize_time, 3600);
        dt_min = ceil(dt_rest / 60);
        digitize_time = sprintf('%02d:%02d', dt_hours, dt_min);
        disp(['Estimated time to digitize requested images: ', digitize_time, ' hours']);
    end

    for j = 1:frames_per_img
        file_name = content(frame_num).name;
        full_file = fullfile(directory,file_name); 

        frame = imread(full_file);

        subarray(j,:,:) = frame; 
        
        frame_num = frame_num + 1; 
    end
    if i == 1
        time1img = toc;
    end
    img = squeeze(sum(uint16(subarray),1)); %sum up frames to create n-bit image

    % extract timestamp from last frame
    pattern = '_(\d{8})_(\d{6})_(\d{3})_'; % change this to your own!
    tokens = regexp(file_name, pattern, 'tokens');
    
    if ~isempty(tokens)
        timestamp = strcat(tokens{1}{1}, '_', tokens{1}{2}, '_', tokens{1}{3});
    else
        timestamp = sprintf('unknown_%d', i); % fallback in case pattern fails
    end
    
    png_file_name = sprintf('spad%d_%s.png', desired_bitdepth, timestamp); % change this to your own!
    png_file_path = fullfile(new_Pdir, png_file_name);
    imwrite(img, colormap_nbit, png_file_path,'png');

    if desired_bitdepth ~= 8 
        frame_num = frame_num + 256 - frames_per_img;
    end
end
close(f);
disp('All images were successfully digitized')