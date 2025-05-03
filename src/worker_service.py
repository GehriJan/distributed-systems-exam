from fastapi import FastAPI
from pydantic import BaseModel
from celery import Celery
import os

app = FastAPI()

# Load environment variables from the corresponding .env file
env_file = os.getenv("ENV_FILE", "src/config/node1.env")  # Default to node1.env
with open(env_file) as f:
    for line in f:
        if line.strip() and not line.startswith("#"):
            key, value = line.strip().split("=", 1)
            os.environ[key] = value

celery_app = Celery("tasks", broker=os.getenv("REDIS_URL", "redis://localhost:6379/0"))

class KeyRequest(BaseModel):
    e: int
    n: int

@app.post("/factorize")
def factorize_key(key: KeyRequest):
    celery_app.send_task("src.tasks.factorize_rsa", args=[key.e, key.n])
    return {"status": "submitted"}