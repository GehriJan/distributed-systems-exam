#!/bin/bash

# Define the nodes and their respective SSH user and IP addresses
NODES=(
    "user@node1_ip"
    "user@node2_ip"
    "user@node3_ip"
    "user@node4_ip"
)

# Define the path to the project directory on each node
REMOTE_PATH="/path/to/remote/distributed-systems-exam"

# Loop through each node and deploy the application
for NODE in "${NODES[@]}"; do
    echo "Deploying to $NODE..."
    
    # Create the remote directory if it doesn't exist
    ssh "$NODE" "mkdir -p $REMOTE_PATH/src/config"
    
    # Copy the necessary files to the remote node
    scp -r src/* "$NODE:$REMOTE_PATH/src/"
    scp -r src/config/*.env "$NODE:$REMOTE_PATH/src/config/"
    
    echo "Deployment to $NODE completed."
done

echo "All nodes have been deployed."