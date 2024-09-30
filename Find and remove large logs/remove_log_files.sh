#!/bin/bash

# Function to check partitions over 80% usage
check_partitions() {
    echo "Checking partitions over 80% usage..."
    df -hP | awk '$5 ~ /[0-9]+%/ {gsub("%", "", $5); if ($5 > 80) print $6}'
}

# Function to find and truncate log files larger than 1GB
truncate_logs() {
    partition=$1
    echo "Searching in partition: $partition"
    
    # Find files larger than 1GB and ending with .log
    find "$partition" -type f -size +1G -name "*.log" -exec bash -c '
        for file; do
            echo "Truncating: $file"
            echo "" > "$file"
        done
    ' bash {} +
}

# Main logic
partitions=$(check_partitions)

# Iterate through each partition and search for large log files
for partition in $partitions; do
    truncate_logs "$partition"
done