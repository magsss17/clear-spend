#!/bin/bash
# Script to resize logo to 1024x1024 for app icon
# Usage: ./resize_logo.sh <input_image> [output_path]

INPUT_FILE="$1"
OUTPUT_FILE="${2:-AppIcon.png}"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: ./resize_logo.sh <input_image> [output_path]"
    echo "Example: ./resize_logo.sh ~/Downloads/logo.png ~/Desktop/AppIcon.png"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found: $INPUT_FILE"
    exit 1
fi

# Resize to 1024x1024 (maintains aspect ratio, adds padding if needed)
echo "Resizing $INPUT_FILE to 1024x1024..."
sips -z 1024 1024 "$INPUT_FILE" --out "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Success! Resized image saved to: $OUTPUT_FILE"
    echo ""
    echo "Now you can:"
    echo "1. Copy it to ClearSpend/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
    echo "2. Or drag it into Xcode's AppIcon asset catalog"
else
    echo "❌ Error resizing image"
    exit 1
fi

