#!/bin/bash

docker stack rm eshop

# ESHOP_AZURE_SERVICE_BUS=eshop_rabbitmq :: docker stack put prefix "eshop_" in all services
DOCKER_FILE_FROM_ENV=`ESHOP_AZURE_SERVICE_BUS=eshop_rabbitmq docker-compose -f ./docker-compose.yml -f ./docker-compose.override.yml --log-level ERROR config`

# docker stack don't use .env data, just docker-compose can do it
echo "$DOCKER_FILE_FROM_ENV" > docker-compose.env.yml && sleep 1

docker stack deploy --compose-file ./docker-compose.env.yml eshop

rm -rf docker-compose.env.yml docker-compose.override.env.yml docker-compose.prod.env.yml