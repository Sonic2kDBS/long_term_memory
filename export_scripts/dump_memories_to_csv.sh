#!/bin/bash

BASE_DIR="./user_data/bot_memories"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")  # Format as YYYYMMDD_HHMMSS
OUTPUT_DIR="./user_data/bot_csv_outputs/$TIMESTAMP"

# Create the output directory
mkdir -p "$OUTPUT_DIR"

# Loop through each directory inside the base directory
for dir in $BASE_DIR/*; do
    if [ -d "$dir" ]; then
        # Get the directory name (which corresponds to the person's name)
        person_name=$(basename "$dir")
        
        # Form the SQLite DB path
        db_path="$dir/long_term_memory.db"
        
        # Form the CSV output path
        csv_output="$OUTPUT_DIR/${person_name}.csv"
        
        echo "Dumping $db_path -> $csv_output"
        # Dump the database content to CSV
        sqlite3 "$db_path" <<EOF
.mode csv
.output "$csv_output"
SELECT * FROM long_term_memory ORDER BY timestamp;
.quit
EOF
    fi
done

