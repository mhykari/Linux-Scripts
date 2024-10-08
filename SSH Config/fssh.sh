#!/bin/bash

# Get the current user running the script
current_user=$(whoami)

# Set the username to connect to the remote host
ssh_username="YOUR_SSH-USERNAME"  # You can modify this to any default username you want

if [ $# -ne 1 ]; then
    echo "Usage: $0 <last_two_octets_or_hostname>"
    exit 1
fi

search_term=$1
ssh_config="$HOME/.ssh/config"

if [ ! -f "$ssh_config" ]; then
    echo "SSH config file not found at $ssh_config"
    exit 1
fi

# Find matching hosts (case-insensitive search)
matches=$(grep -iE "Host|HostName" "$ssh_config" | grep -iE "$search_term" -B 1 | grep "^Host " | awk '{print $2}')

# Check if any matches found
if [ -z "$matches" ]; then
    echo "No matching hosts found."
    exit 1
fi

# Function to extract HostName and Port from the SSH config
get_host_details() {
    local host=$1
    host_ip=$(awk "/^Host $host/,/^$/ { if (\$1 == \"HostName\") print \$2 }" "$ssh_config")
    host_port=$(awk "/^Host $host/,/^$/ { if (\$1 == \"Port\") print \$2 }" "$ssh_config")
    
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
    PS3="Please select the host to connect to: "  # Custom question instead of #?
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
