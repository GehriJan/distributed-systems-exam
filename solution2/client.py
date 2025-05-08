from celery_worker import compute_modular_inverse

result = compute_modular_inverse.delay(5, 19)
print("Task sent. Waiting for result...")
print("Result:", result.get(timeout=10))


import asyncio
import time
import matplotlib.pyplot as plt
import numpy as np
import json
import random



with open('primes.json', 'r') as file:
    primes = json.load(file)

async def fetch_app_output():
    
    p, q = random.sample(primes, 2)  # Randomly select two primes
    phi = (p - 1) * (q - 1)  # Calculate phi
    
    while True:
        e = random.randint(2, phi - 1)  # Randomly select e
        if np.gcd(e, phi) == 1:
            break

    start_time = time.time()  # Start time for the request
    out = compute_modular_inverse.delay(e, phi)  # Call the Celery task
    out = out.get(timeout=10)  # Wait for the result
    end_time = time.time()  # End time for the request

    assert(out * e % phi == 1)  # Check if the result is correct

    return end_time - start_time

durations = []
x = [100, 200, 300, 1000, 2000, 3000, 4000, 5000]


async def run_tasks():
    for num_requests in x:
        tasks = [fetch_app_output() for _ in range(num_requests)]
        durations.append(await asyncio.gather(*tasks))

asyncio.run(run_tasks())



# Calculate statistics for durations
means = [np.mean(d) for d in durations]
q1 = [np.percentile(d, 25) for d in durations]
q3 = [np.percentile(d, 75) for d in durations]
min_vals = [np.min(d) for d in durations]
max_vals = [np.max(d) for d in durations]

# Plot
plt.figure(figsize=(10, 6))

# IQR area
plt.fill_between(x, q1, q3, color='blue', alpha=0.2, label='IQR (25%-75%)')

# Min-Max range (as error bars)
plt.errorbar(x, means, yerr=[np.array(means) - np.array(min_vals), 
                                                        np.array(max_vals) - np.array(means)],
                fmt='o', color='blue', linestyle='--', alpha=0.5, label='Min-Max Range')

# Mean values
plt.plot(x, means, 'o-', color='blue', label='Average Duration')

# Data points
for x, d in zip(x, durations):
    plt.scatter([x]*len(d), d, color='red', s=10, alpha=0.6)

# Axis labels and legend
plt.xlabel('Number of Requests')
plt.ylabel('Duration (ms)')
plt.title('Duration Analysis with Increasing Number of Requests')
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.savefig('duration_analysis.png')