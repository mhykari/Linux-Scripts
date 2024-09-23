#!/bin/bash

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

grep -E "Host|HostName" "$ssh_config" | grep -E "$search_term" -B 1