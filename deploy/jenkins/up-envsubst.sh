#!/bin/bash

# avoid to use env_file=.env in every service in docker-compose

docker stack rm eshop

set -a
source .env

# envsubst < "docker-compose.yml" > "docker-compose.env.yml";
# envsubst < "docker-compose.override.yml" > "docker-compose.override.env.yml";
# envsubst < "docker-compose.prod.yml" > "docker-compose.prod.env.yml";
# docker stack deploy --compose-file ./docker-compose.yml -c ./docker-compose.override.yml eshop
# docker stack deploy --compose-file ./docker-compose.env.yml -c ./docker-compose.override.env.yml eshop

DOCKER_FILE_FROM_ENV=`docker-compose -f ./docker-compose.yml -f ./docker-compose.override.yml config`
sleep 1
echo "$DOCKER_FILE_FROM_ENV" > docker-compose.env.yml
sleep 1

docker stack deploy --compose-file ./docker-compose.env.yml eshop

rm -rf docker-compose.env.yml docker-compose.override.env.yml docker-compose.prod.env.yml

# 1 - up namespace eshop

# 2 - put eshop_rabbitmq on Enterprise Applicatio Log network
docker service update --network-add enterprise_application_log_log eshop_rabbitmq

# 3 - put enterprise_application_log_logstash on eshop_default network
docker service update --network-add eshop_default enterprise_application_log_logstash

# 4 - create vHost EnterpriseLog

# 5 - update payment-api

# 6 - update logstash