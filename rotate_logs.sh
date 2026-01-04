SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROTATED_DIR="$SCRIPT_DIR/rotatedFiles"
TARGET_FILE="$SCRIPT_DIR/logdata.jsonl"
MAX_LINES=20
while true
do
    if [ -f "$TARGET_FILE" ]; then
        LINE_COUNT=$(wc -l < "$TARGET_FILE")

        if [ "$LINE_COUNT" -ge "$MAX_LINES" ]; then
            TIMESTAMP=$(date +%Y-%m-%d__%H-%M-%S)
            BASE_NAME="$(basename "$TARGET_FILE")"
            NEW_NAME="${BASE_NAME}_${TIMESTAMP}.old"
            mv "$TARGET_FILE" "$NEW_NAME"
            touch "$TARGET_FILE"
            
            echo "Log rotated: $TARGET_FILE moved to $NEW_NAME"
        else
            echo "Log is currently at $LINE_COUNT lines. No rotation needed."
        fi
    else
        echo "Target file $TARGET_FILE does not exist. Creating it now..."
        touch "$TARGET_FILE"
    fi
    sleep 60
done
