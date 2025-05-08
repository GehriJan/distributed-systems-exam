from celery_worker import compute_modular_inverse

result = compute_modular_inverse.delay(5, 19)
print("Task sent. Waiting for result...")
print("Result:", result.get(timeout=10))
