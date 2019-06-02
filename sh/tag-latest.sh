#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly CONTAINER_NAME=target

# WIP
# Basic plan is for all the services (eg runner) to tag :latest and
# commander's CI pipe to not tag :latest and use plain .env file.
# Have specific process to create commander image with tagged .env file
# and tag it.

# Assumes already...
#   ./sh/service-puller.sh      # [1] got :latest for all services images
#   ./sh/build_docker_images.sh # [2] built a new commander image with plain .env
#   ./cyber-dojo up             # [3] container is running for all services

# start a container from commander image which does NOT have SHA tags in its .env file
docker run -d -it --name ${CONTAINER_NAME} cyberdojo/commander:latest bash

remove_target_container()
{
  # remove the commander container
  docker rm ${CONTAINER_NAME} --force
}

trap remove_target_container EXIT

# generate new .env file
"${MY_DIR}/dot-env-writer.sh" > /tmp/.env

# copy it into the container
docker cp /tmp/.env ${CONTAINER_NAME}:/app/.env

# docker commit the container to a new tags
readonly VERSION=1.4
docker commit ${CONTAINER_NAME} cyberdojo/commander:${VERSION}
docker tag cyberdojo/commander:${VERSION} cyberdojo/commander:latest
