#!/bin/bash

for file in "$@"; do
    output="${file%.*}-convert.mp4"
    if [ -f "$output" ]; then
        echo "Skipping $file - output already exists: $output"
        continue
    fi
    ffmpeg -fflags +genpts -i "$file" -c:v copy -c:a copy "$output"
done
