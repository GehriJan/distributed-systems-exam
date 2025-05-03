# distributed-systems-exam




## Setup


## Usage

`redis-server --dir src/`

`uvicorn src.client_service:app --port 8000`

`uvicorn src.worker_service:app --port 8001`

`celery -A src.tasks worker --loglevel=info --concurrency=20`

`for i in {1..100}; do curl http://localhost:8000/generate_key & done`