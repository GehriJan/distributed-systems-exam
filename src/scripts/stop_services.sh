#!/bin/bash

# Stop services on each node
NODES=("node1" "node2" "node3" "node4")

for NODE in "${NODES[@]}"; do
    echo "Stopping services on $NODE..."
    ssh "$NODE" "pkill -f 'uvicorn' && pkill -f 'celery'"
done

echo "All services stopped."