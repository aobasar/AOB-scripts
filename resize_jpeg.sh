#!/bin/bash

# Set maximum dimension (width or height)
MAX_DIMENSION=2048

# Set JPEG quality (0–100)
QUALITY=90

# Loop through all .jpg and .jpeg files in the current directory
for FILE in *.jpg *.jpeg; do
  # Skip if no matching files
  [ -e "$FILE" ] || continue

  OUTPUT="small_${FILE}"

  echo "Processing: $FILE -> $OUTPUT"

  # Resize to MAX_DIMENSION (preserves aspect ratio)
  sips -Z $MAX_DIMENSION "$FILE" --out "$OUTPUT"

  # Set JPEG format and compress
  sips --setProperty format jpeg "$OUTPUT"
  sips --setProperty formatOptions $QUALITY "$OUTPUT"
done

echo "✅ All JPEGs resized and compressed!"