#!/bin/bash

# variables defined in .env will be exported into this script's environment:
set -a
source .env

cat docker-compose -f ./docker-compose.yml -f ./docker-compose.override.yml -f ./docker-compose.prod.yml build