# distributed-systems-exam

## Overview
This project implements a distributed system for generating and factorizing RSA keys using FastAPI and Celery. It is designed to run on four nodes in a network, accessible via SSH.

## Setup
To set up the project, follow these steps:

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd distributed-systems-exam
   ```

2. **Install dependencies**:
   Ensure you have Python and pip installed, then run:
   ```
   pip install -r requirements.txt
   ```

3. **Configure environment variables**:
   Each node has its own configuration file located in the `src/config/` directory. Update the `.env` files (`node1.env`, `node2.env`, `node3.env`, `node4.env`) with the appropriate Redis broker URLs and any other necessary configurations.

## Usage
To run the services on the four nodes, use the provided scripts:

1. **Deploy the services**:
   Run the deployment script to copy necessary files and configurations to each node:
   ```
   bash src/scripts/deploy.sh
   ```

2. **Start the services**:
   Start the FastAPI and Celery services on each node:
   ```
   bash src/scripts/start_services.sh
   ```

3. **Stop the services**:
   To stop the services on each node, use:
   ```
   bash src/scripts/stop_services.sh
   ```

## API Endpoints
- **Generate RSA Key**:
  - Endpoint: `GET /generate_key`
  - Description: Generates an RSA key pair and sends the public key and modulus to the worker service for factorization.

- **Factorize RSA Key**:
  - Endpoint: `POST /factorize`
  - Description: Receives the RSA key components and attempts to factorize them using the Celery worker.

## Notes
- Ensure that SSH access is properly configured for each node.
- The Redis server should be running on each node as specified in the environment configuration files.
- The project uses Celery for distributed task processing, which allows for efficient handling of factorization requests across multiple nodes.






## Usage

`redis-server --dir src/`

`uvicorn src.client_service:app --port 8000`

`uvicorn src.worker_service:app --port 8001`

`celery -A src.tasks worker --loglevel=info --concurrency=20`

`for i in {1..100}; do curl http://localhost:8000/generate_key & done`