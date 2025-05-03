# Import statements
from celery import Celery
from Crypto.Util import number
import random

# Set random seed for reproducibility
random.seed(42)
def randfunc(n):
    return bytes([random.getrandbits(8) for _ in range(n)])

app = Celery("tasks", broker="redis://localhost:6379/0")

PRIME_POOL = [number.getPrime(32, randfunc=randfunc) for _ in range(200)]  # Zahlenpool mit Primzahlen

@app.task
def factorize_rsa(e, n):
    print("Length of Prime Pool: " + str(len(PRIME_POOL)))
    print(PRIME_POOL)
    for p in PRIME_POOL:
        if n % p == 0:
            q = n // p
            print(f"Key cracked! p: {p}, q: {q}")
            return p, q
    print("Key not cracked with given pool.")
    return None
