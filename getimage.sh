#!/bin/bash

# Set the name of the Docker image
image_name="mich21050/chromekiosk"

# Set the number of retries
num_retries=10

# Function to check if the Docker image exists
image_exists() {
    docker image inspect "$image_name" &> /dev/null
}

# Function to pull the Docker image
pull_image() {
    echo "Pulling Docker image: $image_name"
    docker pull "$image_name"
}

# Main loop to check if the image exists and pull if necessary
for (( i=1; i<=$num_retries; i++ )); do
    if image_exists; then
        echo "Docker image $image_name exists."
        break
    else
        echo "Docker image $image_name not found. Attempt $i of $num_retries"
        if [ $i -eq $num_retries ]; then
            echo "Max retries reached. Exiting..."
            exit 1
        fi
        pull_image
    fi
done
