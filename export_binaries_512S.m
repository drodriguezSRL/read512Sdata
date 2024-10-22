%{ 
%%%%%%%%%%%%  README  %%%%%%%%%%%%
Original script by David Rodríguez (https://github.com/drodriguezSRL)
Last updated: 2024-Oct-22

Camera: Pi-Imaging SPAD 512S Camera

This script exports a sequence of 1-bit frames in PNG format 
captured during a single acquisition 

NOTE i: Make sure all .BIN files are located in the same directory.
NOTE ii: This script needs the functions 'read_512Sbin.m'.
%}
close all; clear all; clc;

file_path='.\SPAD\noon-on\50.0us'; % change this to your own!
frames_per_bin = 256; 

%%%%%%%%%%%%  PRELIMINARY CALCULATIONS  %%%%%%%%%%%%
disp("Reading directory...")

if ~exist(file_path, 'dir') 
    error('Directory "%s" does not exist.', file_path);
end

file_pattern = fullfile(file_path, '*.bin');
file_list = dir(file_pattern);
totnum_bin = numel(file_list);

fprintf("Total number of bin files to read: %d\n", totnum_bin);

new_Pdir = file_path + "/png/1bit/"; % change this to your own!

if ~exist(new_Pdir, 'dir') 
    mkdir(new_Pdir);
end

%%%%%%%%%%%%  PROCESSING BINARIES  %%%%%%%%%%%%
pattern = '_(\d+\.\d+)_([\d]+)'; % change this to your own!
f = waitbar(0, "Digitizing frames...");

if totnum_bin ~= 0

    for k= 1:(totnum_bin)
        text = "Digitizing frame: " + string(k) + "/" + string(totnum_bin);
        waitbar(k/totnum_bin, f, text);

        if k == 1
        disp('Estimating total digitization time...')
        tic;
        elseif k == 2
            digitize_time = time1img*totnum_bin;
            dt_hours = floor(digitize_time / 3600);
            dt_rest = mod(digitize_time, 3600);
            dt_min = ceil(dt_rest / 60);
            digitize_time = sprintf('%02d:%02d', dt_hours, dt_min);
            disp(['Estimated time to digitize all binary frames: ', digitize_time, ' hours']);
        end

        file_name = file_list(k).name;
        full_filename = fullfile(file_path, file_name);

        % Extract timestamp to add it to new file name
        tokens = regexp(file_name, pattern, 'tokens');
        
        if ~isempty(tokens)
            timestamp = tokens{1}{1};
            wp_num = tokens{1}{2};
        else
            timestamp = sprintf('unknown_%d', i); 
        end
    
        % Extract individual frames within each .bin file
        frames_subarray=read_512Sbin(full_filename);
        frames_subarray= permute(frames_subarray, [3 2 1]);

        % Export binary frames 
        for frame = 1:size(frames_subarray,1) 
            bin_img = squeeze(frames_subarray(frame,:,:));   
            
            % Convert frame to logical array so that binary frames can be
            % saved without normalization with imwrite.
            bin_img = logical(bin_img);
            
            bin_file_name = sprintf('spad_%s_frame%d.png', timestamp, frame); % change this to your own!
            bin_file_path = fullfile(new_Pdir, bin_file_name);
            imwrite(bin_img, bin_file_path, 'png');
        end
        if k == 1
            time1img = toc;
        end
        clear frames_subarray; 
    end
end
close(f);
disp('Binary frames exported succesfully.');

