#!/bin/bash
export MSYS_NO_PATHCONV=1

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHIPPED_DIR="$SCRIPT_DIR/shippedFiles"
HDFS_DEST="/user/data"
DOCKER_TEMP_DIR="/tmp/ingest"
LEDGER_FILE="$SCRIPT_DIR/ingest_ledger.txt"

echo "Initializing HDFS Continuous Ingestor"

echo "Checking HDFS status"
until docker exec namenode hdfs dfsadmin -safemode wait | grep -q "OFF"; do
    echo "HDFS is in Safe Mode."
    sleep 5
done
echo "HDFS is out of Safe Mode."

docker exec namenode hdfs dfs -mkdir -p $HDFS_DEST

transfer_files(){
    for filepath in "$SHIPPED_DIR"/*; do
        [ -e "$filepath" ] || continue
        filename=$(basename "$filepath")

        if grep -qF "$filename" "$LEDGER_FILE"; then
            continue
        else
            echo "File to be transferred: $filename"
            docker exec namenode mkdir -p "$DOCKER_TEMP_DIR"
            win_path=$(cygpath -w "$filepath")
    
            docker cp "$win_path" "namenode:$DOCKER_TEMP_DIR/$filename"

            if [ $? -eq 0 ]; then
                docker exec namenode hdfs dfs -put -f "$DOCKER_TEMP_DIR/$filename" "$HDFS_DEST/"
                docker exec namenode rm "$DOCKER_TEMP_DIR/$filename"
                echo "$filename" >> "$LEDGER_FILE"
                echo "File transferred and logged: $filename"
            else
                echo "Error copying file $filename to Docker container."
                continue
            fi
        fi
    done
}

echo "Starting continuous ingest loop (Press [CTRL+C] to stop)"
while true; do
    transfer_files
    sleep 60
done