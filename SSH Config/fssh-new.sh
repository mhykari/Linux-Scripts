#!/bin/bash

# Get the current user running the script
current_user=$(whoami)

# Set the username to connect to the remote host
ssh_username="Your_Username"  # You can modify this to any default username you want

if [ $# -ne 1 ]; then
    echo "Usage: $0 <hostname_or_ip>"
    exit 1
fi

search_term=$1
ssh_config="$HOME/.ssh/config"

if [ ! -f "$ssh_config" ]; then
    echo "SSH config file not found at $ssh_config"
    exit 1
fi

# Detect if gawk is available
if command -v gawk >/dev/null 2>&1; then
    awk_cmd="gawk"
else
    awk_cmd="awk"
fi

# Convert search term to lowercase for case-insensitive search in non-GNU awk
search_term_lower=$(echo "$search_term" | tr '[:upper:]' '[:lower:]')

# Find exact match first (case-insensitive)
exact_match=$($awk_cmd -v term="$search_term" '
    BEGIN { IGNORECASE = 1 }
    $1 == "Host" && $2 == term { print $2; exit }
' "$ssh_config")

if [ -n "$exact_match" ]; then
    matches="$exact_match"
else
    # Find partial matches (case-insensitive)
    matches=$($awk_cmd -v term="$search_term_lower" '
        BEGIN { IGNORECASE = 1 }
        $1 == "Host" { host = $2; next }
        $1 == "HostName" { hostname = $2; 
          if (tolower(host) ~ term || tolower(hostname) ~ term) print host }
    ' "$ssh_config")
fi

# Check if any matches found
if [ -z "$matches" ]; then
    echo "No matching hosts found."
    exit 1
fi

# Function to extract HostName and Port from the SSH config
get_host_details() {
    local host=$1
    host_ip=$($awk_cmd -v h="$host" '
        BEGIN { IGNORECASE = 1; found = 0; }
        $1 == "Host" { current_host = $2; next }
        $1 == "HostName" && current_host == h { print $2; found = 1; exit }
        END { if (!found) print h }
    ' "$ssh_config")

    host_port=$($awk_cmd -v h="$host" '
        BEGIN { IGNORECASE = 1 }
        $1 == "Host" { current_host = $2; next }
        $1 == "Port" && current_host == h { print $2; exit }
    ' "$ssh_config")

    # Default port is 22 if not defined
    if [ -z "$host_port" ]; then
        host_port=22
    fi
}

# Count the number of matches
match_count=$(echo "$matches" | wc -l)

if [ "$match_count" -eq 1 ]; then
    # If only one match, connect directly
    hostname=$(echo "$matches")
    get_host_details "$hostname"
    echo "Connecting to ##### $hostname ##### (IP: $host_ip, Port: $host_port) as $ssh_username using key of $current_user..."
    ssh -i "/home/$current_user/.ssh/id_rsa" -p "$host_port" "$ssh_username@$host_ip"
    exit 0
else
    # If more than one match, display a list and let the user select
    echo "Matched hosts:"
    PS3="Please select the host to connect to: "
    select hostname in $matches; do
        if [ -n "$hostname" ]; then
            get_host_details "$hostname"
            echo "Connecting to ##### $hostname ##### (IP: $host_ip, Port: $host_port) as $ssh_username using key of $current_user..."
            ssh -i "/home/$current_user/.ssh/id_rsa" -p "$host_port" "$ssh_username@$host_ip"
            exit 0
        else
            echo "Invalid selection. Please try again."
        fi
    done
fi

