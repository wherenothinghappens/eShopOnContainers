#!/bin/bash

# avoid to use env_file=.env in every service in docker-compose

docker stack rm eshop

set -a
source .env

DOCKER_FILE_FROM_ENV=`docker-compose -f ./docker-compose-tests.yml -f ./docker-compose-tests.override.yml config`
sleep 1
echo "$DOCKER_FILE_FROM_ENV" > docker-compose-tests.env.yml
sleep 1

docker stack deploy --compose-file ./docker-compose-tests.env.yml tests

rm -rf docker-compose-tests.env.yml docker-compose.override.env.yml docker-compose.prod.env.yml