#!/bin/bash

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null
then
    echo "ImageMagick is not installed. Please install it and try again."
    exit 1
fi

# Directory containing the .webp files (defaults to the current directory)
DIRECTORY=${1:-$(pwd)}

# Find all .webp files in the directory
for file in "$DIRECTORY"/*.webp
do
    # Check if there are any .webp files
    if [ ! -e "$file" ]; then
        echo "No .webp files found in the directory."
        exit 0
    fi
    
    # Get the base name of the file (without extension)
    BASENAME=$(basename "$file" .webp)

    # Convert the file to .png
    convert "$file" "$DIRECTORY/$BASENAME.png"

    # Check if the conversion was successful
    if [ $? -eq 0 ]; then
        echo "Converted: $file -> $DIRECTORY/$BASENAME.png"
    else
        echo "Failed to convert: $file"
    fi
done
