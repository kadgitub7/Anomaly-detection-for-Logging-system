SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_FOLDER="$SCRIPT_DIR/compressedFiles"
DESTINATION_FOLDER="$SCRIPT_DIR/shippedFiles"
LOG_FILE="$SCRIPT_DIR/ingestion.txt"

while true
do
    if [ -n "$(ls -A "$TARGET_FOLDER" 2>/dev/null)" ]; then
        for file_path in "$TARGET_FOLDER"/*; do
            filename=$(basename "$file_path")
            if grep -Fxq "$filename" "$LOG_FILE"; then
                : 
            else
                cp "$file_path" "$DESTINATION_FOLDER/"
                echo "Shipped File "$filename""
                echo "$filename" >> "$LOG_FILE"
            fi
        done
    fi
    sleep 60
done
