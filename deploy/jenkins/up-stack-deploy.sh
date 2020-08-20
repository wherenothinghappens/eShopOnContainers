#!/bin/bash

docker stack rm eshop

# docker stack don't use .env data, just docker-compose can do it
DOCKER_FILE_FROM_ENV=`docker-compose -f ./docker-compose.yml -f ./docker-compose.override.yml --log-level ERROR config`

echo "$DOCKER_FILE_FROM_ENV" > docker-compose.env.yml && sleep 1

docker stack deploy --compose-file ./docker-compose.env.yml eshop

rm -rf docker-compose.env.yml docker-compose.override.env.yml docker-compose.prod.env.yml