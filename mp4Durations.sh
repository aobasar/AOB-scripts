#!/bin/zsh

for file in *.mp4; do
    duration=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0")
    minutes=$(printf "%02d" $((duration / 60)))
    seconds=$(printf "%02d" $((duration % 60)))
    echo "$file: $minutes:$seconds"
done

