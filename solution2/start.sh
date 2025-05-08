#!/bin/bash

echo "Starte Keepalived..."
keepalived -f /etc/keepalived/keepalived.conf --dont-fork --log-console &

echo "Starte RabbitMQ..."
rabbitmq-server &

sleep 10

echo "Starte Celery-Worker..."
celery -A celery_worker worker --loglevel=info
