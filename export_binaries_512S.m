%{ 
%%%%%%%%%%%%  README  %%%%%%%%%%%%
Original script by David Rodríguez (https://github.com/drodriguezSRL)
Last updated by David Rodríguez on 2024-Sep-23

Camera: Pi-Imaging SPAD 512S Camera

This script exports a sequence of 1-bit frames in PNG format 
captured during a single continous acquisition 

NOTE i: Make sure all .BIN files are located in the same folder and that file
names follow the convention 'RAW_timestamp.bin' (if not, modify read_512Sbin
function)
NOTE ii: This script needs the functions 'read_512Sbin.m' and 'count_BIN.m'
%}
close all; clear all; clc;

%%%%%%%%%%%%  VARIABLES DEFINITION  %%%%%%%%%%%%
% Define file path and frame parameters [USER INPUT]
file_path='C:\Users\davirodr\Documents\Tests\2024.09.20_orbital_test_Niki_v2\SPAD\long_acquisitions\ref_4us_long'; % select data folder

%%%%%%%%%%%%  PRELIMINARY CALCULATIONS  %%%%%%%%%%%%
% Calculate the number of .bin files acquired
file_pattern = fullfile(file_path, 'RAW_*.bin');
file_list = dir(file_pattern);
totnum_bin = length(file_list);

% New directory for PNG images
new_Pdir = file_path + "/png/1bit/";
%check if new directory already exists
if ~exist(new_Pdir, 'dir') %if not, create one
    mkdir(new_Pdir);
end

%%%%%%%%%%%%  PROCESSING BINARIES  %%%%%%%%%%%%
frames_subarray = []; % initialize mega array
f = waitbar(0, "Building subarray...");

if totnum_bin ~= 0
    for k= 1:1:(totnum_bin)
        text = "Building mega array: " + string(k) + "/" + string(totnum_bin);
        waitbar(k/totnum_bin, f, text);

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

        h = waitbar (0, "Saving binary files...");

        % Export binary frames from mega_array and clear array to free up memory
        for frame = 1:size(frames_subarray,1) 
            msg = 'Saving binary frames: ' + string(frame) + '/' + string(size(frames_subarray,1));
            ptg = frame/size(frames_subarray,1);
            waitbar(ptg,h,msg);
            
            bin_img = squeeze(frames_subarray(frame,:,:));   
            
            % Convert frame to logical array so that binary frames can be
            % saved without normalization with imwrite.
            bin_img = logical(bin_img);
            
            % Save binary as PNG
            bin_file_name = new_Pdir + "spad_" + formattedDateStr +  "_frame" + string(frame) + ".png";
            imwrite(bin_img, bin_file_name, 'png')
        end
        clear frames_subarray;
        close(h);
        frames_subarray = [];  
    end
end
fprintf('Binary frames exported succesfully\n');

