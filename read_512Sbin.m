function frames=read_512Sbin(full_filename)

% Open and read the binary file
fileID = fopen(full_filename);
A = fread(fileID, '*uint8');
fclose(fileID);

% Remove the last 4 bytes
A = A(1:end-4);

% Initialize the datamap
%datamap = zeros(512*512, 1);
datamap = zeros(512,512,256);

% Determine the number of frames
nr_images = length(A) * 8 / (512 * 512); %256

% Loop through each image and process the data
for i = 0:(nr_images-1)
    img_index_old = i*512*512/8 + 1; %8355841
    img_index = ((i+1)*512*512)/8; %8388608
    
    dataint = A(img_index_old:img_index); %32768x1 uint8

    % Unpack bits manually
    %databit = zeros(numel(dataint) * 8, 1);
    %for j = 1:numel(dataint)
     %   bits = bitget(dataint(j), 8:-1:1);
      %  databit((j-1)*8 + 1 : j*8) = bits;
    %end
    
    % Unpack bits using dec2bin and reshape
    %bits = reshape(dec2bin(dataint, 8)' - '0', [], 1);
    bits = reshape(dec2bin(dataint, 8)' - '0', [512,512]);
    bits = imrotate(bits, -90); % rotate image 180 deg

    %add bin frame to datamap
    datamap(:,:,i+1) = bits; 
end

% assign to output variable
frames = datamap;

end