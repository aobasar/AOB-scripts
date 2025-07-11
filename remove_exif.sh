#!/bin/bash

# Directory containing images (default is current directory if not provided)
DIR="${1:-.}"

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null
then
    echo "exiftool not found. Install it with: brew install exiftool"
    exit 1
fi

# Loop through image files and remove metadata
echo "Removing EXIF data from images in '$DIR'..."

find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r file; do
    echo "Processing: $file"
    exiftool -all= "$file"
    # Optionally remove backup files created by exiftool
    rm -f "${file}_original"
done

echo "Done."
