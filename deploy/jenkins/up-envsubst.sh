#!/bin/bash

# avoid to use env_file=.env in every service in docker-compose

docker stack rm eshop

set -a
source .env

envsubst < "docker-compose.yml" > "docker-compose.env.yml";
envsubst < "docker-compose.override.yml" > "docker-compose.override.env.yml";
# envsubst < "docker-compose.prod.yml" > "docker-compose.prod.env.yml";

# docker stack deploy --compose-file ./docker-compose.yml -c ./docker-compose.override.yml eshop
# docker stack deploy --compose-file ./docker-compose.env.yml -c ./docker-compose.override.env.yml eshop

docker-compose -f ./docker-compose.env.yml -f ./docker-compose.override.env.yml build # -f ./docker-compose.prod.env.yml 

rm -rf docker-compose.env.yml docker-compose.override.env.yml docker-compose.prod.env.yml


# 1 - up namespace eshop

# 2 - docker service update --network-add enterprise_application_log_log eshop_rabbitmq
docker service update --network-add enterprise_application_log_log eshop_rabbitmq

# 3 - create vHost EnterpriseLog

# 4 - update payment-api

# 5 - update logstash