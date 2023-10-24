#!/bin/bash

# Define the directory to be searched
dir="./root"

# Define the output file
output_file="./all.md5"

# Use find, xargs, and awk to format the filenames and write them to the output file
find "$dir" -type f -print0 | xargs -0 md5sum | awk '{
    gsub(".*/","",$2); 
    gsub(/[^a-zA-Z0-9]/, "_", $2); 
    if ($2 ~ /^[0-9]/) $2 = "file_"$2; 
    print $2"=\""$1"\""
}' >"$output_file"

# Add the completion marker to the end of the file
echo 'ALL_MD5_COMPLETE="true"' >>"$output_file"

#!/bin/bash
