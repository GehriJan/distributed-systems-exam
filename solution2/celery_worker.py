from celery import Celery
from kombu import Queue

app = Celery(
    'tasks',
    broker='amqp://guest:guest@192.168.2.100:5672//',
    backend='rpc://'
)

# Quorum Queue Setup
app.conf.task_queues = [
    Queue('quorum_queue', queue_arguments={'x-queue-type': 'quorum'})
]
app.conf.task_default_queue = 'quorum_queue'
app.conf.task_default_queue_type = 'quorum'
app.conf.broker_transport_options = {"confirm_publish": True}
app.conf.worker_detect_quorum_queues = True

@app.task
def compute_modular_inverse(e, phi):
    """
    Compute the modular inverse using the Extended Euclidean Algorithm.
    :param e: The number e (as an integer).
    :param phi: The number phi (as an integer).
    :return: The modular inverse of e mod phi.
    """
    e = int(e)
    phi = int(phi)
    m0 = phi
    y = 0
    x = 1

    while e > 1:
        q = e // phi
        t = phi

        phi = e % phi
        e = t

        temp = y
        y = x - q * y
        x = temp

    # Ensure x is positive
    if x < 0:
        x += m0

    return x
