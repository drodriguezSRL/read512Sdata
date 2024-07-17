%{ 
%%%%%%%%%%%%  README  %%%%%%%%%%%%
Original script by David Rodríguez (https://github.com/drodriguezSRL)
Last updated by David Rodríguez on 2024-Jul-17

Camera: Pi-Imaging SPAD 512S Camera

This script exports a sequence of 1-bit ("binary") frames in PNG format 
captured during a single acquisition 

NOTE i: Make sure all .BIN files are located in the same folder and that file
names follow the convention 'RAW0000X' (if not, modify read_512Sbin
function)
NOTE ii: This script needs the function read_512Sbin.m 
%}
close all; clear all; clc;

%%%%%%%%%%%%  VARIABLES DEFINITION  %%%%%%%%%%%%
% Define file path and frame parameters [USER INPUT]
file_path='C:/Users/davirodr/Downloads/data_1';

%initialize a mega_array with the frames of the BIN 0
mega_array = read_512Sbin(file_path,0); 
mega_array = permute(mega_array, [3 2 1]);

%%%%%%%%%%%%  PRELIMINARY CALCULATIONS  %%%%%%%%%%%%
% Threshold for memory usage in bytes (e.g., use 50% of available memory)
memory_threshold = 0.5 * check_memory();

% Calculate the number of BIN files created
totnum_BIN = count_BIN(file_path + "/" + 0);

% New directory for PNG images
new_Pdir = file_path + "/png/1bit/";
%check if new directory already exists
if ~exist(new_Pdir, 'dir') %if not, create one
    mkdir(new_Pdir);
end

%%%%%%%%%%%%  PROCESSING BINARIES  %%%%%%%%%%%%
f = waitbar(0, "Building mega array...");
true_frame = 0;

if totnum_BIN > 1

    % Create a larger subarray ("mega") containing all the binary files from ALL the BIN files
    % Export in chunks to prevent memory saturation based on
    % 'memory_threshold'
    for bin_suffix= 1:1:(totnum_BIN-1)
        waitbar(bin_suffix/(10), f, "Building mega array...");
    
        % Call the read_binary function to extract subarray frames
        frames_subarray=read_512Sbin(file_path,bin_suffix);
    
        % Concatenate the new subarray to the existing mega array in the first dimension (i.e., frames)
        mega_array = cat(1, mega_array, frames_subarray);
    
        % Check memory usage (prevent MATLAB from running out of memory when
        % procesing large datasets)
        if whos('mega_array').bytes > memory_threshold
            fprintf('Total number of BIN files that exceeded memory capacity threshold: %.2d\n', bin_suffix);
            h = waitbar (0, "Saving binary files...");

            % Export binary frames from mega_array and clear array to free up
            % memory
            for frame = 1:size(mega_array,1)         
                msg = 'Saving binary frames: ' + string(frame) + '/' + string(size(mega_array,1));
                ptg = frame/size(mega_array,1);
                waitbar(ptg,h,msg);
            
                bin_img = squeeze(mega_array(frame,:,:));   
    
                % Convert frame to logical array so that binary frames can be
                % saved without normalization with imwrite.
                bin_img = logical(bin_img);
                true_frame = true_frame + 1;
    
                bin_file_name = new_Pdir + string(true_frame) + ".png";
                imwrite(bin_img, bin_file_name, 'png')
            end
    
            clear mega_array;
            close(h);
            mega_array = [];
    
            % Recalculate memory threshold
            memory_threshold = 0.5 * check_memory();
        end
    end
end
close(f);

h = waitbar (0, "Saving remaining binary files...");
% Save any remaining frames
if ~isempty(mega_array)
    for frame = 1:size(mega_array,1)
        msg = 'Saving remaining binary frames: ' + string(frame) + '/' + string(size(mega_array,1));
        ptg = frame/size(mega_array,1);
        waitbar(ptg,h,msg);        
        bin_img = squeeze(mega_array(frame,:,:));
        bin_img = logical(bin_img);
        true_frame = 1 + true_frame;      
        bin_file_name = new_Pdir + string(true_frame) + ".png";
        imwrite(bin_img, bin_file_name, 'png')
    end
end
close(h);
fprintf('Binary frames exported succesfully\n');

%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%
% Function to check available memory
function available_memory = check_memory()
    [~, systemview] = memory();
    available_memory = systemview.PhysicalMemory.Available;
end

