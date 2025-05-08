docker kill $(docker ps -q)
docker rm $(docker ps -aq)


docker network rm $(docker network ls -q)