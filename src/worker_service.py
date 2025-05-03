from fastapi import FastAPI
from pydantic import BaseModel
from celery import Celery

app = FastAPI()

celery_app = Celery("tasks", broker="redis://localhost:6379/0")

class KeyRequest(BaseModel):
    e: int
    n: int

@app.post("/factorize")
def factorize_key(key: KeyRequest):
    celery_app.send_task("src.tasks.factorize_rsa", args=[key.e, key.n])
    return {"status": "submitted"}
