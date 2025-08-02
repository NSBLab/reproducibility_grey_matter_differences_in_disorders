#!/bin/bash

# Define the input and output file (adjust the file path as needed)
input_file=/home/trangc/kg98_scratch/Data_Trang/ASD_brain45/image03.txt
output_file=/home/trangc/kg98/trangc/VBM/data/Brain45/extracted_paths.txt

# Clear the output file if it exists
> "$output_file"

# Read and process the file
while IFS=' ' read -r collection_id image_file dataset_id
do
    # Extract the part of the path after 'submission*/'
    file_location=$(echo "$image_file" )

    # Write the extracted path to the output file
    echo "$file_location" >> "$output_file"

done < "$input_file"

# Notify that the process is complete
echo "Extracted paths have been written to $output_file"

