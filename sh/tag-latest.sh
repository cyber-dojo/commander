#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly CONTAINER_NAME=target

# Assumes already...
#   ./sh/service-puller.sh      # [1] got :latest copies of all services
#   ./sh/build_docker_images.sh # [2] built a new commander image
#   ./cyber-dojo up             # [3] started a server

# start a container from commander image which does NOT have SHA tags in its .env file
docker run -d -it --name ${CONTAINER_NAME} cyberdojo/commander:latest bash

# generate new .env file
"${MY_DIR}/dot-env-writer.sh" > /tmp/.env

# copy it into the container
docker cp /tmp/.env ${CONTAINER_NAME}:/app/.env

# docker commit the container to a new image
docker commit ${CONTAINER_NAME} cyberdojo/commander:latest

# remove the commander container
docker rm ${CONTAINER_NAME} --force
