%{ 
%%%%%%%%%%%%  README  %%%%%%%%%%%%
Original script by David Rodríguez (https://github.com/drodriguezSRL)
Last updated by David Rodríguez on 2024-Jul-17

Works with data from the following cameras: 
- SwissSPAD2 Top Half array (512x256)
- Pi-Imaging SPAD512S (512x512)

This script builds up and exports a sequence of n-bit frames in PNG format 
captured during a single acquisition. 

NOTE: 1-bit frames need to be exported first using
- 'export_binaries_ss2TH.m' for data acquired with the SwissSPAD2
- 'export_binaries_512S.m' for data acquired with the SPAD512S
%}
close all; clear all; clc;

%%%%%%%%%%%%  VARIABLES DEFINITION  %%%%%%%%%%%%
% Define file path and frame parameters [USER INPUT]
file_path='C:/Users/davirodr/Downloads/data/intensity_images/acq00000';
bit_path='/png/1bit/';
no_rows=512;
no_columns=512;
readout_time = 0.25e-6; %readout time per binary frame in s
acq_time = 4; %total acquistion time in s
exp_time = 0.5e-6; % exposure time in s
frame_period = 15e-6; %frame period in s
illuminance = 250; %lux 

% Autocalc of number of 1-bit frames in file_path
directory = strcat(file_path,bit_path);
content = dir(directory);
if ~exist(directory, 'dir') % Check if the directory exists
    % If the directory does not exist, display an error message and stop execution
    error('Directory "%s" does not exist. Make sure binary frames have been previously exported to PNG.', content);
end
totnum_frames = length(content)-2; %always subtract 2 since length takes into account the current (.) and parent (..) directories
fprintf('Total number of existing 1-bit frames in this folder: %.2d\n', totnum_frames);

% Define desired bit depth and starting/end frame
desired_bitdepth = 4;
starting_frame = 1; % starting 1-bit frame 1='1.png'.

% Define number of n-bit frames to export. Leave 0 for max number of n-bit
% frame possible.
num_frames = 0; 
if num_frames == 0
    num_frames = totnum_frames/(2^desired_bitdepth);
end

% New directory for PNG images
new_Pdir = file_path + "/png/"+string(desired_bitdepth)+"bit/";
%check if new directory already exists
if ~exist(new_Pdir, 'dir') %if not, create one
    mkdir(new_Pdir);
end

% Create a colormap for n grayscale levels
colormap_nbit = gray(2^desired_bitdepth); % Generates a n-level grayscale colormap required for saving n-bit PNGs lower than 8-bit

% Instantiate array with starting frame
array = imread(append(file_path,bit_path,string(starting_frame),'.png'));
new_array = reshape(array, [1, size(array,1), size(array,2)]);

%%%%%%%%%%%%  EXPORT FRAMES  %%%%%%%%%%%%
% Build large array with required 1-bit frames
end_frame = starting_frame + num_frames*2^desired_bitdepth - 1; 

f = waitbar(0, "Building array...");
for i = starting_frame+1:1:end_frame
    msg = 'Building array: frame ' + string(i) + '/' + string(end_frame);
    ptg = i/end_frame;
    waitbar(ptg,f,msg);

    frame = imread(append(file_path,bit_path,string(i),'.png')); % read new frame
    frame = reshape(frame, [1, size(frame,1), size(frame,2)]); % from 2D to 3D array
    new_array = cat(1, new_array, frame); % append new frame into large array containing all frames
end
close(f);

% Create a meshgrid for pixel coordinates (for matlab display only)
[buf, true_rows, true_cols] = size(frame);
[x, y] = meshgrid(1:true_cols, 1:true_rows);

h = waitbar (0, "Saving n-bit frames...");
frame_no = 1;

figure;
hold on;
% Display and save nbit images as a PNG files
for i = 1:2^desired_bitdepth:size(new_array,1)
    msg = 'Saving n-bit frames: ' + string(frame_no) + '/' + string(num_frames);
    ptg = frame_no/num_frames;
    waitbar(ptg,h,msg);
    
    img = squeeze(sum(uint16(new_array(i:(i+2^desired_bitdepth-1),:,:)),1));    
    
    % Save each frame as a PNG file
    png_file_name = string(frame_no)+ '.png';
    png_file_path = new_Pdir + png_file_name;
    %imwrite(uint8(flip_img),png_file_path,'png');
    imwrite(img, colormap_nbit, png_file_path,'png');

    % PLOTTING
    % Plot each frame as a surface in the 3D plot
    rot_img = imrotate(img, 180);
    flip_img = flip(rot_img,2);
    z = (10^3*frame_no*frame_period*2^desired_bitdepth) * ones(size(flip_img)); % Create a constant z-plane for the time step
    surf(x, z, y, double(flip_img), 'EdgeColor', 'none')  
    
    % Plot each frame as a 2D image
    %figure;
    %imagesc(flip_img)
    %pbaspect([2 1 1]) %ensure image is displayed with the correct aspect ratio   
    %colormap gray; %change colormap to grayscale instead of the deafult jet
    %colorbar;  % Display the colorbar for reference
    %caxis([0 (2^bit_depth-1)]);  % Set color axis limits to match the 4-bit image range
    %axis off;  % Remove both x-axis and y-axis
 
    frame_no = frame_no + 1;
end
close(h);

% Adjust 3D plot properties
colormap(gray); % Use grayscale colormap
colorbar; % Add a colorbar
xlabel('Pixel X');
ylabel('Time (ms)');
zlabel('Pixel Y');
title('Sequence of 2D Images in 3D Plot');
view(3); % Set the view to 3D
hold off;