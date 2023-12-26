#!/bin/bash

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
    echo "Error: exiftool not found. Please install it first."
    exit 1
fi

# Check if files are provided as arguments
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file1.jpg> [<file2.jpg> ...]"
    exit 1
fi

# Loop through each provided file and remove EXIF data
for file in "$@"; do
    if [ -f "$file" ]; then
        echo "Removing EXIF data from $file"
        exiftool -all= "$file"
    else
        echo "File not found: $file"
    fi
done

echo "Done."
