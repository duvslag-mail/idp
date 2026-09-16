#!/bin/bash

# source: https://blog.mikesahari.com/posts/html-templating/

# Find all templ files
find ./templates -name "*.templ" | while read -r src_file; do
    # Calculate destination path
    rel_path=${src_file#./templates/}
    dir_name=$(dirname "$rel_path")
    file_name=$(basename "$rel_path")
    dest_dir="./internal/$dir_name"

    # Create output directory
    mkdir -p "$dest_dir"

    # Run templ on the file and capture output
    templ generate -f "$src_file" -stdout > "$dest_dir/${file_name%.templ}_templ.go"
done