function num_BIN=count_BIN(file_path)
nBIN = 0; %initialize total number of BIN files

% Calculate the number of subfolders within the results folder
content = dir(file_path);
num_subfolder = length(content)-2; %always subtract 2 since length takes into account the current (.) and parent (..) directories

% Get into every subfolder and count+add the number of BIN files.
for folder = 0:(num_subfolder-1) 
    folder_path = file_path + "/" + num2str(folder);
    folder_content = dir(folder_path);
    nBIN =  nBIN + (length(folder_content)-2);
end

% Assign the processed binary data to the output variable
num_BIN = nBIN;
end 