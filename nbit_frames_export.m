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
file_path='C:\Users\davirodr\Documents\Tests\2024.09.20_orbital_test_Niki_v2\SPAD\long_acquisitions\sunfacing_0.1us_long';
bit_path='/png/1bit/';
no_rows=512;
no_columns=512;
readout_time = 0.25e-6; %readout time per binary frame in s
acq_time = 4; %total acquistion time in s
exp_time = 0.5e-6; % exposure time in s
frame_period = 15e-6; %frame period in s
illuminance = 250; %lux 


%%%%%%%%%%%%  PRELIMINARY CALCULATIONS  %%%%%%%%%%%%
% Calculate the number of .png files 
directory = strcat(file_path,bit_path);
content = dir(directory);
if ~exist(directory, 'dir') % Check if the directory exists
    % If the directory does not exist, display an error message and stop execution
    error('Directory "%s" does not exist. Make sure binary frames have been previously exported to PNG.', content);
end
totnum_frames = length(content)-2; %always subtract 2 since length takes into account the current (.) and parent (..) directories
fprintf('Total number of existing 1-bit frames in this folder: %.2d\n', totnum_frames);

% Define desired bit depth and starting/end frame
desired_bitdepth = 8;

% starting 1-bit frame
starting_frame = content(3); % starting 1-bit frame. content(1)='.', content(2)='..'. Frames start in (3).

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



f = waitbar(0, "Building subarray...");

text = "Building subarray: " + string(k) + "/" + string(totnum_bin);
waitbar(k/totnum_bin, f, text);

% go over the list of n-bit frames that could be created 1 by 1 
for i = 1:1:num_frames
    msg = 'Building subarray: frame ' + string(i) + '/' + string(num_frames);
    ptg = i/num_frames;
    waitbar(ptg,f,msg);
    
    % for each n-bit frame sum up as many 1-bit frames as needed.
    for k = 1:1:2^desired_bitdepth
        msg = 'Saving n-bit frames: ' + string(frame_no) + '/' + string(num_frames);
        ptg = frame_no/num_frames;
        waitbar(ptg,h,msg);
        
        img = squeeze(sum(uint16(new_array(i:(i+2^desired_bitdepth-1),:,:)),1));    

        % the file should be named with an average timestamp among all the 1-bit frames captured
        %to be done...
        
        % Save each frame as a PNG file
        png_file_name = string(frame_no)+ '.png';
        png_file_path = new_Pdir + png_file_name;
        %imwrite(uint8(flip_img),png_file_path,'png');
        imwrite(img, colormap_nbit, png_file_path,'png');
     
        frame_no = frame_no + 1;
    end



    % Get the file name
        file_name = file_list(k).name;
        full_filename = fullfile(file_path, file_name);

        % Extract timestamp to add it to new file name
        [~, name, ~] = fileparts(file_name);
        tokens = regexp(name, 'RAW_(\d+\.\d+)', 'tokens');
            
        % Convert python timestamp to datetime format 
        timestamp = str2double(tokens{1}{1});
        datetimeValue = datetime(timestamp, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
        formattedDateStr = datestr(datetimeValue, 'yyyymmdd_HHMMSS_FFF');
    
        % Call the read_binary function to extract subarray frames
        frames_subarray=read_512Sbin(full_filename);
        frames_subarray= permute(frames_subarray, [3 2 1]);


    frame = imread(append(file_path,bit_path,string(i),'.png')); % read new frame
    frame = reshape(frame, [1, size(frame,1), size(frame,2)]); % from 2D to 3D array
    new_array = cat(1, new_array, frame); % append new frame into large array containing all frames



end
close(f);

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
 
    frame_no = frame_no + 1;
end
close(h);

