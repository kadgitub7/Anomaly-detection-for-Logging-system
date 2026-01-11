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
            target_filename="${filename%.gz}"
            echo "Renaming for Spark compatibility: $target_filename"

            docker exec namenode mkdir -p "$DOCKER_TEMP_DIR"
            win_path=$(cygpath -w "$filepath")
            docker cp "$win_path" "namenode:$DOCKER_TEMP_DIR/$target_filename"

            if [ $? -eq 0 ]; then
                docker exec namenode hdfs dfs -put -f "$DOCKER_TEMP_DIR/$target_filename" "$HDFS_DEST/"
                docker exec namenode rm "$DOCKER_TEMP_DIR/$target_filename"

                echo "$filename" >> "$LEDGER_FILE"
                echo "File transferred and logged: $target_filename"
            else
                echo "Error copying file $filename to Docker container."
                exit 1
            fi
        fi
    done
}

echo "Starting ingest (Press [CTRL+C] to stop)"

if transfer_files; then
    echo "Files moved to HDFS. Signaling Spark..."
    docker exec namenode hdfs dfs -touchz "$HDFS_DEST/_SUCCESS"
    echo "BATCH_COMPLETE $(date)" >> "$LEDGER_FILE"
    echo "Batch ingestion complete."
    echo "Ingestion Complete Starting Spark Job Next"

    echo "Ingestion Complete Starting Spark Job Next"
    sleep 5
    docker cp spark.py spark-master:/tmp/spark.py

    if docker exec spark-master ls /tmp/spark.py >/dev/null 2>&1; then
        echo "Confirmed: spark.py is inside the container."
        docker exec spark-master /spark/bin/spark-submit \
            --master local[*] \
            --packages com.mysql:mysql-connector-j:8.3.0 \
            /tmp/spark.py
    fi
    echo "Job is completed. Check SQL database for results."
    sleep 20
else
    echo "Ingestion failed. Spark job aborted."
    exit 1
fi
