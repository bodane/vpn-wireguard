#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root or with sudo."
    exit 1
fi

# Set the username as a variable
read -p "Enter the username you want to create: " USERNAME

# Create a new user with a home directory
useradd -m -s /bin/bash "$USERNAME"

# Set a password for the new user
passwd "$USERNAME"

# Give the new user sudo privileges
usermod -aG sudo "$USERNAME"

# Install git and nano
apt update
apt install -y git nano

# Install Docker
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce

# Add the new user to the Docker group
usermod -aG docker "$USERNAME"

# Display success message
echo "User $USERNAME created, added to sudo and docker groups, and git, nano, and Docker installed."
