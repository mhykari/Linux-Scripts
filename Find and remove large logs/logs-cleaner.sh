#!/bin/bash

# Configurations for each pattern (max size, number of files to keep, and mtime)
declare -A PATTERN_CONFIGS=(
    ["logs-cleaner.log"]="5M:0:"      # Max total size of files: 5MB, keep 0 newest files, no mtime filter
    ["dca-log-*.log"]="100M:1:+1"     # Max total size of files: 100MB, keep 2 newest files, mtime: files older than 1 day
    ["messages_*.log"]="1G:1:"    # Max total size of files: 100MB, keep 2 newest files, mtime: files older than 1 day
    ["messages-*"]="1G:1:"    # Max total size of files: 100MB, keep 2 newest files, mtime: files older than 1 day
    ["myApp.*.log"]="100M:2:+1"       # Max total size of files: 100MB, keep 2 newest files, mtime: files older than 1 day
    ["los-log*.log"]="100M:4:"        # Max total size of files: 100MB, keep 2 newest files, no mtime filter
    ["localhost_access_log.*.txt"]="100M:2:"  # Max total size of files: 100MB, keep 2 newest files, no mtime filter
    ["http_access*.log"]="100M:2:"    # Max total size of files: 100MB, keep 2 newest files, no mtime filter
    ["SystemOut_*.log"]="100M:1:+1"   # Max total size of files: 100MB, keep 1 newest file, mtime: files older than 1 day
    ["SystemOut.log"]="5G:0:"   # Max total size of files: 100MB, keep 1 newest file, mtime: files older than 1 day
    ["SystemErr.log"]="5G:0:"   # Max total size of files: 100MB, keep 1 newest file, mtime: files older than 1 day
    ["StatementSupplementaryMqApp*.log"]="200M:1:"  # Max total size of files: 50MB, keep 1 newest file, no mtime filter
    ["StatementSupplementaryMqApp*.log*"]="200M:1:"  # Max total size of files: 50MB, keep 1 newest file, no mtime filter
    ["*json.log"]="500M:0:"           # Max total size of files: 200MB, keep 2 newest files, no mtime filter
    ["*json.log.*"]="3G:0:"         # Max total size of files: 200MB, keep 2 newest files, no mtime filter
    ["statementMetrics.*.log"]="100M:0:+1"  # Max total size of files: 100MB, keep 0 newest files, mtime: files older than 1 day
    ["logFile*.log"]="100M:0:"        # Max total size of files: 100MB, keep 0 newest files, no mtime filter
    ["samatApp.*.log"]="500M:2:"      # Max total size of files: 500MB, keep 2 newest files, no mtime filter
    ["*.journal"]="1G:0:"           # Max total size of files: 100MB, keep 2 newest files, no mtime filter
    ["myapp*.zip"]="50M:0:+1"         # Max total size of files: 50MB, keep 2 newest files, mtime: files older than 1 day
    ["myApp*.zip"]="50M:0:+1"         # Max total size of files: 50MB, keep 2 newest files, mtime: files older than 1 day
    ["myApp.*!myApp.*.zip"]="1G:0:"  # Max total size of files: 50MB, keep 1 newest file, no mtime filter
    ["metrics.log"]="100M:0:+1"       # Max total size of files: 100MB, keep 0 newest files, mtime: files older than 1 day
    ["spring.log*"]="100M:0:+1"       # Max total size of files: 100MB, keep 0 newest files, mtime: files older than 1 day
    ["api-mgmt.log*"]="100M:0:+1"     # Max total size of files: 100MB, keep 0 newest files, mtime: files older than 1 day
    ["api-mgmt.log"]="5G:0:"     # Max total size of files: 100MB, keep 0 newest files, mtime: files older than 1 day
    ["icms-log.*.log"]="100M:1:"      # Max total size of files: 100MB, keep 1 newest file, no mtime filter
    ["phk-*.log"]="100M:2:+3"         # Max total size of files: 100MB, keep 2 newest files, mtime: files older than 3 days
    ["console.log"]="300M:0:"         # Max total size of files: 300MB, keep 0 newest files, no mtime filter
    ["JPAoutput.log"]="1G:0:"         # Max total size of files: 1GB, keep 0 newest files, no mtime filter
    ["webatmserver.log"]="1G:0:"      # Max total size of files: 1GB, keep 0 newest files, no mtime filter
    ["spring.log*.gz"]="10M:0:+3"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["hazelcast.log*"]="10M:0:+5"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["messages.1"]="1G:0:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["messages"]="1G:0:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["fluent-bit.log*"]="100M:0:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["loan-batch.log"]="5G:0:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["spring.log"]="5G:0:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["personApp.log"]="5G:0:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["bmiAuditLog.*!bmiAuditLog.*.zip"]="500M:1:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["bmiAuditLog.*.zip"]="500M:10:"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    ["octa-app.*.log"]="50M:5:1"     # Max total size of files: 10MB, keep 0 newest files, mtime: files older than 3 days
    )
# Paths and patterns for emptying files
# Extra Paths :  
declare -A PATHS_AND_PATTERNS_EMPTY=(
    ["/opt/"]='SystemErr.log SystemOut.log octa-app.*.log spring.log bmiAuditLog.*!bmiAuditLog.*.zip loan-batch.log fluent-bit.log* hazelcast.log* webatmserver.log dca-log-*.log messages_*.log myApp.*.log los-log*.log localhost_access_log.*.txt http_access*.log SystemOut_*.log phk-*.log api-mgmt.log api-mgmt.log* console.log JPAoutput.log'
    ["/var/lib/docker/"]='*json.log.* StatementSupplementaryMqApp*.log StatementSupplementaryMqApp*.log* *json.log statementMetrics.*.log samatApp.*.log phk-*.log metrics.log icms-log.*.log spring.log* logFile*.log'
    ["/var/log/journal/"]='*.journal'
    ["/var/lib/docker/overlay2/*/*/opt/ibm/wlp/usr/servers/*/"]='myApp.*!myApp.*.zip'
    ["/var/log/logs-cleaner/"]='logs-cleaner.log'
    ["/var/log/"]='messages.1 messages messages-*'
    ["/opt/logs/"]='personApp.log spring.log'
    ["/tmp/"]='spring.log*'
)

# Paths and patterns for deleting files
# Extra Paths :  ["/opt/"]='spring.log*.gz'
declare -A PATHS_AND_PATTERNS_DELETE=(
    ["/var/lib/docker/"]='myapp*.zip myApp*.zip'
    ["/opt/"]='bmiAuditLog.*.zip'
)


# Function to convert human-readable size (like 1G, 500M) to bytes
convert_size_to_bytes() {
    local SIZE=$1
    echo $(( $(numfmt --from=iec $SIZE) ))
}

# Function to find files by directory, pattern, and optional mtime, sorted by modification time
find_files_by_dir() {
    local DIR_PATH=$1
    local PATTERN=$2
    local MTIME=$3  # Add mtime parameter

    # Check if DIR_PATH contains wildcard characters like '*' or '?'
    if [[ "$DIR_PATH" == *'*'* || "$DIR_PATH" == *'?'* ]]; then
        # Remove both single quote types (' and ‘) if wildcard is present
        DIR_PATH=${DIR_PATH//\'/}
        DIR_PATH=${DIR_PATH//‘/}
    fi

    # Initialize NAME_PATTERN and NEGATE_PATTERN
    local NAME_PATTERN="$PATTERN"
    local NEGATE_PATTERN=""

    # Check if PATTERN contains '!'
    if [[ "$PATTERN" == *'!'* ]]; then
        # Use cut to separate the patterns
        NAME_PATTERN=$(echo "$PATTERN" | cut -d '!' -f 1)   # Part before '!'
        NEGATE_PATTERN=$(echo "$PATTERN" | cut -d '!' -f 2) # Part after '!'
    fi

    # Prepare the find command
    local FIND_CMD=("find")

    # Add DIR_PATH to the find command
    if [[ "$DIR_PATH" == *'*'* || "$DIR_PATH" == *'?'* ]]; then
        FIND_CMD+=($DIR_PATH)  # Add DIR_PATH without quotes if it contains wildcards
    else
        FIND_CMD+=("$DIR_PATH")  # Add DIR_PATH with quotes if it doesn't contain wildcards
    fi

    FIND_CMD+=("-type" "f" "-name" "$NAME_PATTERN" "-size" "+1M")

    # Add negate pattern to the find command if specified
    if [[ -n "$NEGATE_PATTERN" ]]; then
        FIND_CMD+=("!" "-name" "$NEGATE_PATTERN")
    fi

    # If mtime is specified, add it to the find command
    if [[ -n "$MTIME" ]]; then
        FIND_CMD+=("-mtime" "$MTIME")
    fi

    # Execute the find command, sort the files by modification time
    "${FIND_CMD[@]}" -exec stat --format "%Y %n" {} \; | sort -n | cut -d ' ' -f2-
}
find_empty_files() {
    local dir_path="$1"
    local pattern="$2"
    local mtime="${3:-9}"  # پیش‌فرض 5 روز
    find "$dir_path" -type f -name "$pattern" -size 0c -atime +$mtime 2>/dev/null
}

delete_old_files() {
    local DIR=$1
    local PATTERN=$2
    local FILES=("${@:3}")

    # Log file path to store deleted file information in /var/log/logs-cleaner
    LOG_DIR="/var/log/logs-cleaner"
    LOG_FILE="${LOG_DIR}/logs-cleaner.log"

    # Check if the log directory exists, if not create it
    if [[ ! -d "$LOG_DIR" ]]; then
        echo "Directory $LOG_DIR does not exist. Creating it..."
        mkdir -p "$LOG_DIR"
    fi

    # Initialize the log file (optional, can append instead)
    echo "Deletion Log for Pattern '$PATTERN' - $(date)" >> "$LOG_FILE"
    echo "-----------------------------------------------" >> "$LOG_FILE"

    CONFIG=${PATTERN_CONFIGS[$PATTERN]}

    if [[ -z "$CONFIG" ]]; then
        echo "Warning: No config found for pattern: $PATTERN"
        return
    fi

    # Split the config into size, keep count, and mtime
    IFS=':' read -r MAX_SIZE KEEP_COUNT MTIME <<< "$CONFIG"
    
    # Validate the values of MAX_SIZE, KEEP_COUNT, and MTIME
    if [[ -z "$MAX_SIZE" || -z "$KEEP_COUNT" ]]; then
        echo "Error: Invalid configuration for pattern '$PATTERN'."
        return
    fi
    if [[ -z "$MTIME" ]]; then
        MTIME=""  # If no MTIME is provided, leave it empty
    fi
    
    # Convert the max size to bytes
    MAX_SIZE=$(convert_size_to_bytes "$MAX_SIZE")

    echo "Max allowed size for pattern $PATTERN: $MAX_SIZE bytes"
    echo "Keeping $KEEP_COUNT newest files"

    # Sort files by modified time (newest first)
    SORTED_FILES=($(ls -t "${FILES[@]}" 2>/dev/null))

    # Apply KEEP_COUNT: Keep the newest files
    if [[ $KEEP_COUNT -gt 0 ]]; then
        FILES_TO_KEEP=("${SORTED_FILES[@]:0:$KEEP_COUNT}")
        FILES_TO_DELETE=("${SORTED_FILES[@]:$KEEP_COUNT}")
    else
        FILES_TO_KEEP=()
        FILES_TO_DELETE=("${SORTED_FILES[@]}")
    fi

    # Calculate the total size of the files to delete
    TOTAL_SIZE=0
    for FILE in "${FILES_TO_DELETE[@]}"; do
        FILE_SIZE=$(stat --format="%s" "$FILE")
        TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
    done

    echo "Total size of files to delete: $TOTAL_SIZE bytes"

    # Check if the total size of files to delete is greater than MAX_SIZE
    if [[ $TOTAL_SIZE -le $MAX_SIZE ]]; then
        echo "Total size of files to delete is under the limit. No files will be deleted."
        return
    else
        # If total size exceeds MAX_SIZE, proceed to delete files
        echo "Total size exceeds the limit. Proceeding to delete files..."

        for FILE in "${FILES_TO_DELETE[@]}"; do
            FILE_SIZE=$(stat --format="%s" "$FILE")

            echo "Deleting $FILE ($FILE_SIZE bytes)..."
            rm -f "$FILE"  # Delete the file

            TOTAL_SIZE=$((TOTAL_SIZE - FILE_SIZE))
            echo "New total size: $TOTAL_SIZE bytes"

            # Log the deletion in the log file
            DELETE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$DELETE_TIME - Deleted $FILE ($FILE_SIZE bytes)" >> "$LOG_FILE"

            # If the remaining total size is less than or equal to MAX_SIZE, stop the deletion process
            if [[ $TOTAL_SIZE -le $MAX_SIZE ]]; then
                echo "Remaining files are below the max size. Stopping deletion."
                break
            fi
        done
    fi
}

# Function to empty large files based on conditions
empty_large_files() {
    local DIR=$1
    local PATTERN=$2
    local FILES=("${@:3}")

    # Log file path to store deleted file information in /var/log/logs-cleaner
    LOG_DIR="/var/log/logs-cleaner"
    LOG_FILE="${LOG_DIR}/logs-cleaner.log"

    # Check if the log directory exists, if not create it
    if [[ ! -d "$LOG_DIR" ]]; then
        echo "Directory $LOG_DIR does not exist. Creating it..."
        mkdir -p "$LOG_DIR"
    fi

    # Initialize the log file (optional, can append instead)
    echo "Emptying Files Log for Pattern '$PATTERN' - $(date)" >> "$LOG_FILE"
    echo "-----------------------------------------------" >> "$LOG_FILE"

    # Check if the pattern exists in PATTERN_CONFIGS
    if [[ -z "$PATTERN" || -z "${PATTERN_CONFIGS[$PATTERN]}" ]]; then
        echo "Error: No configuration found for pattern '$PATTERN' in directory '$DIR'."
        return
    fi

    CONFIG="${PATTERN_CONFIGS[$PATTERN]}"

    # Split the config into size, keep count, and mtime
    IFS=':' read -r MAX_SIZE KEEP_COUNT MTIME <<< "$CONFIG"
    
    # Validate the values of MAX_SIZE, KEEP_COUNT, and MTIME
    if [[ -z "$MAX_SIZE" || -z "$KEEP_COUNT" ]]; then
        echo "Error: Invalid configuration for pattern '$PATTERN'."
        return
    fi
    if [[ -z "$MTIME" ]]; then
        MTIME=""  # If no MTIME is provided, leave it empty
    fi

    # Convert the max size to bytes
    MAX_SIZE=$(convert_size_to_bytes "$MAX_SIZE")

    echo "Max allowed size for pattern '$PATTERN' in directory '$DIR': $MAX_SIZE bytes."
    echo "Keeping $KEEP_COUNT newest files."

    # If KEEP_COUNT > 0: Keep the specified number of newest files
    if [[ $KEEP_COUNT -gt 0 ]]; then
        # Check if there are more files than KEEP_COUNT
        if [[ ${#FILES[@]} -gt $KEEP_COUNT ]]; then
            # Files to empty are the oldest ones (those not in the KEEP_COUNT newest files)
            NUM_FILES_TO_EMPTY=$(( ${#FILES[@]} - KEEP_COUNT ))
            FILES_TO_EMPTY=("${FILES[@]:0:$NUM_FILES_TO_EMPTY}")

            echo "Identified $NUM_FILES_TO_EMPTY oldest files to empty."

            # Calculate the total size of files to empty
            TOTAL_SIZE_TO_EMPTY=0
            for FILE in "${FILES_TO_EMPTY[@]}"; do
                FILE_SIZE=$(stat -c%s "$FILE")
                echo "Size of file '$FILE' to be emptied: $FILE_SIZE bytes."
                TOTAL_SIZE_TO_EMPTY=$((TOTAL_SIZE_TO_EMPTY + FILE_SIZE))
            done

            echo "Total size of files to empty: $TOTAL_SIZE_TO_EMPTY bytes."

            # Check if we need to empty any files based on MAX_SIZE
            if [[ $TOTAL_SIZE_TO_EMPTY -le $MAX_SIZE ]]; then
                echo "Total size of files to empty is already below the maximum size limit. No need to empty files."
                return
            else
                # Loop over the oldest files and empty them one by one
                for FILE in "${FILES_TO_EMPTY[@]}"; do
                    FILE_SIZE=$(stat -c%s "$FILE")
                    echo "Processing file '$FILE' with size $FILE_SIZE bytes."

                    # Check if reducing the file size will bring total size below MAX_SIZE
                    REMAINING_SIZE=$((TOTAL_SIZE_TO_EMPTY - FILE_SIZE))
                    if [[ $REMAINING_SIZE -lt $MAX_SIZE ]]; then
                        # Calculate how much space we need to free
                        SIZE_TO_FREE=$((TOTAL_SIZE_TO_EMPTY - MAX_SIZE))
                        SIZE_TO_TRUNCATE=$((FILE_SIZE - SIZE_TO_FREE))

                        # Truncate file
                        echo "Truncating file '$FILE' to free $SIZE_TO_FREE bytes (new size will be $SIZE_TO_TRUNCATE bytes)."
                        truncate -s "$SIZE_TO_TRUNCATE" "$FILE"
                        echo "File '$FILE' truncated successfully."

                        # Log the truncation
                        DELETE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
                        echo "$DELETE_TIME - Truncated $FILE to free $SIZE_TO_FREE bytes" >> "$LOG_FILE"
                        
                        break  # Stop after adjusting this file
                    else
                        # Subtract the file's size from the total size to empty and empty the file completely
                        TOTAL_SIZE_TO_EMPTY=$((TOTAL_SIZE_TO_EMPTY - FILE_SIZE))
                        > "$FILE"  # Empty the file by truncating its content
                        echo "File '$FILE' has been emptied completely."

                        # Log the deletion
                        DELETE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
                        echo "$DELETE_TIME - Emptying $FILE ($FILE_SIZE bytes)" >> "$LOG_FILE"
                    fi

                    echo "Updated total size of files to empty: $TOTAL_SIZE_TO_EMPTY bytes."

                    # If the total size to empty is now less than or equal to max size, stop emptying files
                    if [[ $TOTAL_SIZE_TO_EMPTY -le $MAX_SIZE ]]; then
                        echo "Remaining total size of files to empty is below the maximum size limit. Stopping emptying."
                        break
                    fi
                done
            fi
        fi
    elif [[ $KEEP_COUNT -eq 0 ]]; then
        # If KEEP_COUNT is 0, empty all files starting from the oldest
        if [[ ${#FILES[@]} -gt 0 ]]; then
            echo "Emptying all files starting from the oldest in directory '$DIR'."
            # First, calculate the total size of all files before emptying
            TOTAL_SIZE=0
            for FILE in "${FILES[@]}"; do
                FILE_SIZE=$(stat -c%s "$FILE")
                TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
            done
            echo "Initial total size of all files: $TOTAL_SIZE bytes."

            # Start from the oldest file and move towards the newest one
            for ((i=0; i<${#FILES[@]}; i++)); do
                FILE="${FILES[$i]}"
                FILE_SIZE=$(stat -c%s "$FILE")
                echo "Checking file '$FILE' with size $FILE_SIZE bytes."

                # Check if emptying the file will bring the total size below MAX_SIZE
                if [[ $TOTAL_SIZE -le $MAX_SIZE ]]; then
                    echo "Total size is now within the allowed limit of $MAX_SIZE bytes. Stopping emptying."
                    break
                fi

                # If the total size is still greater than MAX_SIZE, proceed with emptying the file
                echo "Emptying file '$FILE' with size $FILE_SIZE bytes."

                # Check if emptying the file will bring the total size below MAX_SIZE
                if [[ $((TOTAL_SIZE - FILE_SIZE)) -lt $MAX_SIZE ]]; then
                    # Calculate how much space we need to free to reach MAX_SIZE
                    SIZE_TO_FREE=$((TOTAL_SIZE - MAX_SIZE))

                    # Truncate the file to free the required amount of space
                    echo "Trimming $SIZE_TO_FREE bytes from file '$FILE'."
                    truncate -s "-$SIZE_TO_FREE" "$FILE"
                    echo "File '$FILE' trimmed successfully."

                    # Log the trimming
                    DELETE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
                    echo "$DELETE_TIME - Trimmed $SIZE_TO_FREE bytes from $FILE" >> "$LOG_FILE"
                    
                    break  # Exit the loop as we've reached the desired size
                else
                    # Subtract the file's size from the total size
                    TOTAL_SIZE=$((TOTAL_SIZE - FILE_SIZE))
                    # If we still have room, empty the file completely
                    > "$FILE"  # Empty the file by truncating its content
                    echo "File '$FILE' has been emptied completely."

                    # Log the deletion
                    DELETE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
                    echo "$DELETE_TIME - Emptying $FILE ($FILE_SIZE bytes)" >> "$LOG_FILE"
                fi
            done
        fi
    fi
}


# Step 1: Find all files for each path and pattern (empty large files)
ALL_FILES=()
for DIR_PATH in "${!PATHS_AND_PATTERNS_EMPTY[@]}"; do
    PATTERNS="${PATHS_AND_PATTERNS_EMPTY[$DIR_PATH]}"
    echo "Searching for patterns '$PATTERNS' in directory: $DIR_PATH"
    
    # Split the patterns by spaces to process each one separately
    IFS=' ' read -r -a PATTERN_ARRAY <<< "$PATTERNS"
    
    # Process each pattern individually
    for PATTERN in "${PATTERN_ARRAY[@]}"; do
        echo "Processing pattern: $PATTERN"

        # Get the configuration for the current pattern
        CONFIG=${PATTERN_CONFIGS[$PATTERN]}
        if [[ -z "$CONFIG" ]]; then
            echo "Warning: No config found for pattern: $PATTERN"
            continue
        fi

        # Split the config into size, keep count, and optional mtime
        IFS=':' read -r MAX_SIZE KEEP_COUNT MTIME <<< "$CONFIG"

        # Find files using the directory, pattern, and mtime if provided
        FILES=($(find_files_by_dir "$DIR_PATH" "$PATTERN" "$MTIME"))

        # If no files are found for this pattern, just continue to the next one
        if [[ ${#FILES[@]} -eq 0 ]]; then
            echo "No files found matching the pattern '$PATTERN' in directory $DIR_PATH."
            continue
        fi

        # Append the found files along with their pattern to the ALL_FILES array
        for FILE in "${FILES[@]}"; do
            ALL_FILES+=("$PATTERN:$FILE")
        done
    done
done

# Step 2: Group files by their directories
declare -A DIRS_TO_FILES_EMPTY
declare -A pattern_files

for FILE_PATTERN in "${ALL_FILES[@]}"; do
    # Separate the pattern and file using ':' as the delimiter
    IFS=':' read -r PATTERN FILE <<< "$FILE_PATTERN"
    
    DIR_NAME=$(readlink -f "$(dirname "$FILE")")  # Fix here to use readlink -f
    # Ensure the directory exists and is valid before using it in an array
    if [[ -n "$DIR_NAME" && -d "$DIR_NAME" ]]; then
        DIRS_TO_FILES_EMPTY["$DIR_NAME"]+="$PATTERN:$FILE|"
    fi
done

# Step 3: For each directory, process the files
for DIR in "${!DIRS_TO_FILES_EMPTY[@]}"; do
    echo "Processing files in directory: $DIR"
    
    # Convert concatenated string to an array (separate by '|')
    FILES=(${DIRS_TO_FILES_EMPTY["$DIR"]//|/ })

    # Initialize a new array to store only the file names and patterns separately
    FILES_ONLY=()
    PATTERNS=()

    # Group files by their pattern
    for FILE_PATTERN in "${FILES[@]}"; do
        IFS=':' read -r PATTERN FILE <<< "$FILE_PATTERN"    
        # Append file to the corresponding pattern group
        pattern_files["$PATTERN"]+="$FILE "
    done
    # Iterate over each pattern and call empty_large_files for each group
    for PATTERN in "${!pattern_files[@]}"; do
        # Get the files associated with the current pattern
        FILES_GROUP=(${pattern_files["$PATTERN"]})

        # Call the function for each pattern with its associated files
        empty_large_files "$DIR" "$PATTERN" "${FILES_GROUP[@]}"
        unset pattern_files["$PATTERN"]
        FILES_GROUP=()
    done
done

# Step 2: Process each directory and pattern for deleting old files
declare -A DIRS_TO_FILES_DELETE
declare -A pattern_files_DELETE
# Step 1: Find all files for each path and pattern (delete old files)
ALL_FILES=()
for DIR_PATH in "${!PATHS_AND_PATTERNS_DELETE[@]}"; do
    PATTERNS="${PATHS_AND_PATTERNS_DELETE[$DIR_PATH]}"
    echo "Searching for patterns '$PATTERNS' in directory: $DIR_PATH"
    
    # Split the patterns by spaces to process each one separately
    IFS=' ' read -r -a PATTERN_ARRAY <<< "$PATTERNS"
    
    # Process each pattern individually
    for PATTERN in "${PATTERN_ARRAY[@]}"; do
        echo "Processing pattern: $PATTERN"

        # Get the configuration for the current pattern
        CONFIG=${PATTERN_CONFIGS[$PATTERN]}
        if [[ -z "$CONFIG" ]]; then
            echo "Warning: No config found for pattern: $PATTERN"
            continue
        fi

        # Split the config into size, keep count, and optional mtime
        IFS=':' read -r MAX_SIZE KEEP_COUNT MTIME <<< "$CONFIG"

        # Find files using the directory, pattern, and mtime if provided
        FILES=($(find_files_by_dir "$DIR_PATH" "$PATTERN" "$MTIME"))

        # If no files are found for this pattern, just continue to the next one
        if [[ ${#FILES[@]} -eq 0 ]]; then
            echo "No files found matching the pattern '$PATTERN' in directory $DIR_PATH."
            continue
        fi

        # Append the found files along with their pattern to the ALL_FILES array
        for FILE in "${FILES[@]}"; do
            ALL_FILES+=("$PATTERN:$FILE")
        done
    done
done

# Step 2: Group files by their directories
for FILE_PATTERN in "${ALL_FILES[@]}"; do
    # Separate the pattern and file using ':' as the delimiter
    IFS=':' read -r PATTERN FILE <<< "$FILE_PATTERN"
    
    DIR_NAME=$(readlink -f "$(dirname "$FILE")")  # Fix here to use readlink -f
    # Ensure the directory exists and is valid before using it in an array
    if [[ -n "$DIR_NAME" && -d "$DIR_NAME" ]]; then
        DIRS_TO_FILES_DELETE["$DIR_NAME"]+="$PATTERN:$FILE|"
    fi
done

# Step 3: For each directory, process the files and delete them
for DIR in "${!DIRS_TO_FILES_DELETE[@]}"; do
    echo "Processing files in directory: $DIR"
    
    # Convert concatenated string to an array (separate by '|')
    FILES=(${DIRS_TO_FILES_DELETE["$DIR"]//|/ })

    # Initialize a new array to store only the file names and patterns separately
    FILES_ONLY=()
    PATTERNS=()
    
    # Group files by their pattern
    for FILE_PATTERN in "${FILES[@]}"; do
        IFS=':' read -r PATTERN FILE <<< "$FILE_PATTERN"    
        # Append file to the corresponding pattern group
        pattern_files_DELETE["$PATTERN"]+="$FILE "
    done
    # Iterate over each pattern and call empty_large_files for each group
    for PATTERN in "${!pattern_files_DELETE[@]}"; do
        # Get the files associated with the current pattern
        FILES_GROUP=(${pattern_files_DELETE["$PATTERN"]})

        # Call the function for each pattern with its associated files
        delete_old_files "$DIR" "$PATTERN" "${FILES_GROUP[@]}"
        unset pattern_files_DELETE["$PATTERN"]
        FILES_GROUP=()
    done
done

for DIR_PATH in "${!PATHS_AND_PATTERNS_EMPTY[@]}"; do
    PATTERNS="${PATHS_AND_PATTERNS_EMPTY[$DIR_PATH]}"
    echo "Deleting Empty Files Process: Searching for patterns '$PATTERNS' in directory: $DIR_PATH"
    
    IFS=' ' read -r -a PATTERN_ARRAY <<< "$PATTERNS"
    # مسیر لاگ
    LOG_DIR="/var/log/logs-cleaner"
    LOG_FILE="${LOG_DIR}/logs-cleaner.log"

    # ایجاد مسیر لاگ اگر وجود ندارد
    if [[ ! -d "$LOG_DIR" ]]; then
        echo "Directory $LOG_DIR does not exist. Creating it..."
        mkdir -p "$LOG_DIR"
    fi

    # لاگ ابتدایی برای دایرکتوری
    echo "-----------------------------------------------" >> "$LOG_FILE"
    echo "Deletion Empty Files Log for Directory '$DIR_PATH' - $(date)" >> "$LOG_FILE"

    
    for PATTERN in "${PATTERN_ARRAY[@]}"; do
        echo "Processing pattern: $PATTERN"  
        FILES=($(find_empty_files "$DIR_PATH" "$PATTERN" "9"))

        if [[ ${#FILES[@]} -eq 0 ]]; then
            echo "No Empty-files found matching the pattern '$PATTERN' in directory $DIR_PATH."
            echo "$(date +"%Y-%m-%d %H:%M:%S") - No Empty-files found for pattern '$PATTERN' in directory $DIR_PATH." >> "$LOG_FILE"
            continue
        fi

        for FILE in "${FILES[@]}"; do
            DELETE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
            echo "Deleting file: $FILE"
            echo "$DELETE_TIME - Deleted $FILE " >> "$LOG_FILE"
            rm -f "$FILE"
        done
    done
    echo "Deletion Empty Files process completed for directory '$DIR_PATH' - $(date)" >> "$LOG_FILE"
    echo "-----------------------------------------------" >> "$LOG_FILE"
done

# Get today's date in YYYY-MM-DD format
TODAY=$(date +"%Y-%m-%d")

# Print today's logs from the log file
# Log file path to store deleted file information in /var/log/logs-cleaner
LOG_DIR="/var/log/logs-cleaner"
LOG_FILE="${LOG_DIR}/logs-cleaner.log"

echo "Today's logs from $LOG_FILE:"
grep "$TODAY" "$LOG_FILE"
