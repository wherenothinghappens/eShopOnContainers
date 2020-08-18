#!/bin/bash

# avoid to use env_file=.env in every service in docker-compose

set -a
source .env

# envsubst < "docker-compose.yml" > "docker-compose.env.yml";
# envsubst < "docker-compose.override.yml" > "docker-compose.override.env.yml";
# envsubst < "docker-compose.prod.yml" > "docker-compose.prod.env.yml";

# docker stack deploy --compose-file ./docker-compose.yml -c ./docker-compose.override.yml eshop
# docker stack deploy --compose-file ./docker-compose.env.yml -c ./docker-compose.override.env.yml eshop

DOCKER_FILE_FROM_ENV=`docker-compose -f ./docker-compose.yml -f ./docker-compose.override.yml --log-level ERROR config`
sleep 1
echo "$DOCKER_FILE_FROM_ENV" > docker-compose.env.yml
sleep 1

docker-compose -f ./docker-compose.env.yml build 

rm -rf docker-compose.env.yml docker-compose.override.env.yml docker-compose.prod.env.yml