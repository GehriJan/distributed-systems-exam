# filepath: /Users/jannisgehring/code/distributed-systems-lecture/distributed-systems-exam/src/client_service.py
from fastapi import FastAPI
from pydantic import BaseModel
from Crypto.Util import number
import requests
import random

# Set random seed for reproducibility
random.seed(42)
def randfunc(n):
    return bytes([random.getrandbits(8) for _ in range(n)])

# Initialize FastAPI app
app = FastAPI()

NUMBERS_POOL = [number.getPrime(32, randfunc=randfunc) for _ in range(10000)]  # Zahlenpool mit Primzahlen

class RSAKeyResponse(BaseModel):
    public_key: int
    modulus: int

@app.get("/generate_key", response_model=RSAKeyResponse)
def generate_key():
    p, q = random.sample(NUMBERS_POOL, 2)
    n = p * q
    e = 65537

    # Send key to cluster
    print(requests.post("http://localhost:8001/factorize", json={"e": e, "n": n}))

    return {"public_key": e, "modulus": n}