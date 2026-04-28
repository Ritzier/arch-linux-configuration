#!/bin/bash

for file in "$@"; do
    output="${file%.*}-h265.mp4"
    if [ -f "$output" ]; then
        echo "Skipping $file - output already exists: $output"
        continue
    fi
    ffmpeg -i "$file" -c:v libx265 -vtag hvc1 -c:a copy "$output"
done
