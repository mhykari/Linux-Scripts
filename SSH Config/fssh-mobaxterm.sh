#!/bin/bash

# Get the current user running the script
current_user=root

# Set the username to connect to the remote host
ssh_username="root"  # You can modify this to any default username you want

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

# Find exact match first (case-insensitive)
exact_match=$(awk -v term="$search_term" '
    tolower($1) == "host" && tolower($2) == tolower(term) {
        print $2
        exit
    }
' "$ssh_config")

if [ -n "$exact_match" ]; then
    matches="$exact_match"
else
    # Find partial matches (case-insensitive)
    matches=$(awk -v term="$search_term" '
        tolower($1) == "host" {
            host = $2
            next
        }
        tolower($1) == "hostname" {
            hostname = $2
            if (tolower(host) ~ tolower(term) || tolower(hostname) ~ tolower(term))
                print host
        }
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

    host_ip=$(awk -v h="$host" '
        BEGIN { found = 0 }
        tolower($1) == "host" {
            current_host = $2
            next
        }
        tolower($1) == "hostname" && tolower(current_host) == tolower(h) {
            print $2
            found = 1
            exit
        }
        END {
            if (!found)
                print h
        }
    ' "$ssh_config")

    host_port=$(awk -v h="$host" '
        tolower($1) == "host" {
            current_host = $2
            next
        }
        tolower($1) == "port" && tolower(current_host) == tolower(h) {
            print $2
            exit
        }
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
