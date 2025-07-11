#!/bin/bash

# Parse -url=... argument
for arg in "$@"; do
  case $arg in
    -url=*)
      url="${arg#*=}"
      shift
      ;;
  esac
done

if [ -z "$url" ]; then
  echo "Usage: $0 -url=https://example.com/playlist.m3u8"
  exit 1
fi

# Setup working directory
mkdir -p video_parts
cd video_parts || exit 1

# Download m3u8 playlist
curl -L "$url" -o playlist.m3u8

# Extract full .ts URLs (POSIX-safe)
urls=()
while IFS= read -r line; do
  if echo "$line" | grep -qE "^https?://"; then
    urls+=("$line")
  fi
done < playlist.m3u8

# Validate
if [ ${#urls[@]} -eq 0 ]; then
  echo "❌ No .ts segment URLs found. The playlist might have relative paths or is encrypted."
  exit 1
fi

# Download segments
i=0
for segment_url in "${urls[@]}"; do
  filename="part_$i.ts"
  echo "Downloading $segment_url → $filename"
  curl -L "$segment_url" -o "$filename"
  ((i++))
done

# Create file_list.txt for ffmpeg
> file_list.txt
for j in $(seq 0 $((i-1))); do
  echo "file 'part_${j}.ts'" >> file_list.txt
done

# Merge with ffmpeg
echo "Merging into output.mp4..."
ffmpeg -f concat -safe 0 -i file_list.txt -c copy ../output.mp4