#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Install required packages
echo "Installing required packages..."
sudo apt install -y \
    curl \
    wget \
    vim \
    git \
    zip \
    rsync \
    htop \
    python3 \
    less \
    lsof \
    iotop \
    dstat \
    sysstat \
    tree \
    net-tools \
    dnsutils \
    tcpdump \
    traceroute \

# Add any additional packages here
# sudo apt install -y <package_name>

# Clean up
echo "Cleaning up..."
sudo apt autoremove -y

echo "All packages installed successfully!"