# Cluster-Verbindung für rabbit2
docker exec rabbit2 rabbitmqctl stop_app
docker exec rabbit2 rabbitmqctl reset
docker exec rabbit2 rabbitmqctl join_cluster rabbit@rabbit1
docker exec rabbit2 rabbitmqctl start_app

# Cluster-Verbindung für rabbit3
docker exec rabbit3 rabbitmqctl stop_app
docker exec rabbit3 rabbitmqctl reset
docker exec rabbit3 rabbitmqctl join_cluster rabbit@rabbit1
docker exec rabbit3 rabbitmqctl start_app

# Cluster-Verbindung für rabbit4
docker exec rabbit4 rabbitmqctl stop_app
docker exec rabbit4 rabbitmqctl reset
docker exec rabbit4 rabbitmqctl join_cluster rabbit@rabbit1
docker exec rabbit4 rabbitmqctl start_app

# Cluster-Status prüfen
docker exec rabbit1 rabbitmqctl cluster_status