%{ 
%%%%%%%%%%%%  README  %%%%%%%%%%%%
Original script by David Rodríguez (https://github.com/drodriguezSRL)
Last updated: 2024-Oct-06

Remapped 4-bit frames to 8-bit colormap PNGs
%}
close all; clear all; clc;

img_path='.\intensity_images\acq00004'; % change to your own!

disp("Reading directory...")

img_files = dir(fullfile(img_path, '*.png')); 
num_imgs = numel(img_files);

first_img = imread(fullfile(img_path, img_files(1).name));
[rows, cols] = size(first_img);

if ~exist(img_path, 'dir') 
    error('Directory "%s" does not exist. Make sure binary frames have been previously exported to PNG.', content);
end

% Threshold for memory usage in bytes (e.g., use 50% of available memory)
memory_threshold = 0.5 * check_memory();

colormap_8bit = gray(256);

img_array = first_img;

new_Pdir = img_path + "/remap/"; 
if ~exist(new_Pdir, 'dir') 
    mkdir(new_Pdir);
end

disp("Building array of images...hold on")
k = 1;
batch_size = 100;
for i = 100:batch_size:num_imgs
    img = imread(fullfile(img_path, img_files(i).name));

    img_array = cat(3, img_array, img); 

    if whos('img_array').bytes > memory_threshold
        disp("Ouchy, we went over the memory threshold...wait a sec while I free up some ")

        img_array = uint8(img_array .* 16);  

        for j = 1:size(img_array,3)
            disp("I'm gonna have to remapped some images first...")
            
            png_file_name = img_files(k).name;
            png_file_path = fullfile(new_Pdir, png_file_name);
            imwrite(img_array(:,:,j), colormap_8bit, png_file_path,'png');

            k = k + batch_size;
        end

        clear img_array;
        img_array = [];

        disp("Ok, we are back in business!")
    end
end

disp("Saving the rest of remapped images...")

if ~isempty(img_array)
    img_array = uint8(img_array .* 16); 
    for j = 1:size(img_array,3)          
        png_file_name = img_files(k).name;
        png_file_path = fullfile(new_Pdir, png_file_name);
        imwrite(img_array(:,:,j), colormap_8bit, png_file_path,'png');
        
        k = k + batch_size;
    end
end
disp("I'm all done!")

function available_memory = check_memory()
    [~, systemview] = memory();
    available_memory = systemview.PhysicalMemory.Available;
end