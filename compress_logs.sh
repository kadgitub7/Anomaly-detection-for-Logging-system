SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROTATED_DIR="$SCRIPT_DIR/rotatedFiles"
TARGET_FOLDER="$SCRIPT_DIR/compressedFiles"

while true
do
    if [ -z "$(ls -A "$ROTATED_DIR" 2>/dev/null)" ]; then
        echo "No compression operation performed: 0 Files in rotatedFiles"
    else
        for file in "$ROTATED_DIR"/*; do
            if [ -f "$file" ]; then
                echo "Compressing $file..."
                gzip "$file"
                mv "${file}.gz" "$TARGET_FOLDER"
            fi
        done
    fi
    sleep 60
done
