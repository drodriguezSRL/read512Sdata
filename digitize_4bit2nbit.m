%{ 
%%%%%%%%%%%%  README  %%%%%%%%%%%%
Original script by David Rodríguez (https://github.com/drodriguezSRL)
Last updated: 2024-Oct-22

Works with 4-bit data frames as an input. The scripts exports a sequence of
n-bit frames in PNG format.

%}
close all; clear all; clc;

%%%%%%%%%%%%  VARIABLES DEFINITION  %%%%%%%%%%%%
file_path='.\dawn-off\backwards\spad'; % change this to your own!
bit_path='/png/1bit/'; % change this to your own!
no_rows=512;
no_cols=512;

desired_bitdepth = 8;

if desired_bitdepth < 4
    error ('Images cannot be digitized to a lower bit depth than that of the input data.\n Please select a desired bit depth > 4.')
end

%%%%%%%%%%%%  PRELIMINARY CALCULATIONS  %%%%%%%%%%%%
disp("Reading directory...")

if ~exist(file_path, 'dir') 
    error('Directory "%s" does not exist. Make sure binary frames have been previously exported to PNG.', content);
end

content = dir(fullfile(file_path, '*.png'));
totnum_frames = numel(content);

fprintf('Total number of 4-bit frames: %d\n', totnum_frames);

frames_per_img = (2^desired_bitdepth)/16;
fprintf('Desired bitdept: %d\n', desired_bitdepth)

% Define number of n-bit images to export. Leave 0 for max number of n-bit
% images possible.
num_images = 0; 
if num_images == 0
    num_images = totnum_frames/frames_per_img;
end
fprintf('Total number of images to digitize: %.2d\n', num_images);

new_Pdir = file_path + "/png/" + string(desired_bitdepth) + "bit/";
if ~exist(new_Pdir, 'dir')
    mkdir(new_Pdir);
end

colormap_nbit = gray(2^desired_bitdepth); 

%%%%%%%%%%%%  EXPORT FRAMES  %%%%%%%%%%%%
% Images will be exported 1 by 1 based at the desired_bitdepth.
% This means that if 8-bit is selected, 16 4-bit frames will be read at a time
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
    img = squeeze(sum(uint16(subarray),1)); 
    pattern = '_(\d{8})_(\d{6})_(\d{3})_'; % change this to your own!
    tokens = regexp(file_name, pattern, 'tokens');
    
    if ~isempty(tokens)
        timestamp = strcat(tokens{1}{1}, '_', tokens{1}{2}, '_', tokens{1}{3}); % change this to your own!
    else
        timestamp = sprintf('unknown_%d', i); 
    end
    
    % save n-bit PNG file
    png_file_name = sprintf('spad%d_%s.png', desired_bitdepth, timestamp); % change this to your own!
    png_file_path = fullfile(new_Pdir, png_file_name);
    imwrite(img, colormap_nbit, png_file_path,'png');

    if desired_bitdepth ~= 8 
        frame_num = frame_num + 256 - frames_per_img; 
    end
end
close(f);
disp('All images were successfully digitized')