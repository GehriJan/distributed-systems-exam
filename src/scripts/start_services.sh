#!/bin/bash

# Define the nodes and their respective SSH user
NODES=("node1" "node2" "node3" "node4")
USER="your_ssh_user"  # Replace with your SSH username

# Start services on each node
for NODE in "${NODES[@]}"; do
    echo "Starting services on $NODE..."
    ssh "$USER@$NODE" "source /path/to/env/bin/activate && \
    redis-server --dir /path/to/redis/data/ && \
    uvicorn src.worker_service:app --host 0.0.0.0 --port 8001 & \
    celery -A src.tasks worker --loglevel=info --concurrency=20 &"
done

echo "All services started."