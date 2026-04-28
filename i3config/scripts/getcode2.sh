#!/usr/bin/env bash

patterns=()
ignore_dir=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    --pattern)
        patterns+=("$2")
        shift 2
        ;;
    --ignore)
        ignore_dir="$2"
        shift 2
        ;;
    *)
        echo "Unknown argument: $1"
        exit 1
        ;;
    esac
done

if [ ${#patterns[@]} -eq 0 ]; then
    echo "Error: at least one --pattern is required"
    exit 1
fi

# Build find expression for patterns
find_expr=()
for i in "${!patterns[@]}"; do
    if [ $i -gt 0 ]; then
        find_expr+=("-o")
    fi
    find_expr+=("-path" "*${patterns[$i]}*")
done

# Build ignore expression
ignore_expr=()

# ignore user-specified directory
if [ -n "$ignore_dir" ]; then
    ignore_expr+=(-not -path "*/$ignore_dir/*")
fi

# always ignore .git
ignore_expr+=(
    -not -path "*/.git/*"
    -not -path "*/target/*"
    -not -path "*/node_modules/*"
    -not -path "*/__pycache__/*"
)

# ignore file types
ignore_expr+=(
    -not -name "*.png"
    -not -name "*.mp4"
    -not -name "*.mp3"
    -not -name "*.jpg"
    -not -name "*.jpeg"
    -not -name "*.ttf"
)

# Run search
find . \
    \( "${find_expr[@]}" \) \
    "${ignore_expr[@]}" \
    -type f \
    -exec sh -c '
        echo "===== FILE: $1 ====="
        cat "$1"
        echo
    ' sh {} \;
