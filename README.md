# SPAD512S Data Reader
***This repository contains a series of MATLAB scripts designed to read and export data acquired with Pi-Imaging SPAD512S camera***

## Structure 
### Repository structure
This repository contains 4 files:
- *export_binaries_512S.m*
- *nbit_frames_export.m*
- *read_512Sbin.m*
- *count_BIN.m*

### Data structure
The scripts contained in this repository are meant to work with the data structure created by default by the camera GUI. 

> [!NOTE]
> The scripts within this repository are only meant to work based on 1-bit frame acquisitions.  

From the SPAD512S, data is saved by default based on the following directory structure:
```
> ...
    > data
        > intensity_images
            > acq0000X
                > RAW00000.bin
                > RAW00001.bin
                > ...
```

`RAW0000X.BIN` are binary files containing a maximum of 1000 1-bit frames (i.e., ~32MB). Multiple .BIN files will be saved during longer acquisitions. 

The scripts are designed to work regardless of the number of .BIN files saved but always within single acquisitions (i.e., the file path to the `acq0000X` folder of choice needs to be defined within the `export_binaries_512S.m` script). The scripts will need to be modified for them to read data from multiple acquisitions at once. 

## Short files description
#### *export_binaries_512S* ####
This file reads all the .BIN files saved during a single acquisition and extracts and exports each 1-bit frame acquired as individual .PNG files.

#### *nbit_frames_export* ####
Once the 1-bit frames have been exported to PNG, this script can build up n-bit .PNG images out of those 1-bit frames. The required bit depth can be explicitly defined within the script. 

#### *read_512Sbin* ####
This is a function required by the `export_binaries_512S.m`script. This function contains the necessary code to extract and reconstruct the data from a .BIN file so that single 1-bit frames can be exported. This script is based on the `python_tcp_stream_binary_intensity1bit.py` file available in the SPAD512S system documentation [1](#references).

#### *count_BIN* ####
This script contains a simple function to count the number of .BIN files saved during a single acquisition

## References
1. [SPAD512S System Documentation](https://piimaging.com/doc-spad512s)


