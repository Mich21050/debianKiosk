#!/bin/bash

# Set the name of the Docker image
image_name="mich21050/chromekiosk"

# Function to check if the Docker image exists
image_exists() {
    docker image inspect "$image_name" &> /dev/null
}

# Function to pull the Docker image
pull_image() {
    echo "Pulling Docker image: $image_name"
    docker pull "$image_name"
}

# Check if the image exists
if ! image_exists; then
    echo "Docker image $image_name not found."

    # Check for internet connectivity
    echo "Checking internet connectivity..."
    while ! ping -c 1 -W 3 google.com &> /dev/null; do
        echo "Internet not reachable. Retrying in 5 seconds..."
        sleep 5
    done
    echo "Internet is reachable."

    # Pull the image
    pull_image
else
    echo "Docker image $image_name exists. No action needed."
fi
