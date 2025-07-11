#!/bin/bash

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null
then
    echo "exiftool is not installed. Please install it first."
    exit 1
fi

# Directory containing JPEG files
directory="$1"

# Check if directory argument is provided
if [ -z "$directory" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory $directory does not exist."
    exit 1
fi

# Remove EXIF data from all JPEG files in the directory
for file in "$directory"/*.JPG "$directory"/*.JPEG "$directory"/*.jpg "$directory"/*.jpeg
do
    if [ -f "$file" ]; then
        echo "Removing EXIF data from $file..."
        exiftool -all= "$file"
        # Remove the backup file created by exiftool
        rm -f "${file}_original"
    fi
done

echo "EXIF data removed from all JPEG files in $directory."
