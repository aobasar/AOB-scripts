#!/bin/bash

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "No JPG files selected."
    exit 1
fi

# Prompt the user for the order of files
echo "Choose the order to combine files:"
echo "1) A to Z (alphabetical)"
echo "2) Z to A (reverse alphabetical)"
read -p "Enter 1 or 2: " order_choice

# Sort files based on user input
if [ "$order_choice" == "1" ]; then
    files=($(printf "%s\n" "$@" | sort))
elif [ "$order_choice" == "2" ]; then
    files=($(printf "%s\n" "$@" | sort -r))
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Debugging: Output the paths of the files being processed
echo "Files to be processed: ${files[@]}"

# Get the directory and filename of the first file (after sorting)
output_dir=$(dirname "${files[0]}")
first_file=$(basename "${files[0]}")
filename_without_extension="${first_file%.*}"

# Debugging: Show where the output will be saved
output_file="$output_dir/${filename_without_extension}.pdf"
echo "Output PDF will be saved as: $output_file"

# Combine the JPG files into a PDF
echo "Running convert command..."
convert "${files[@]}" "$output_file"

# Check if the PDF was created
if [ -f "$output_file" ]; then
    echo "PDF successfully created: $output_file"
else
    echo "Failed to create PDF."
fi
