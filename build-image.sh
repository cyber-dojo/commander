#!/bin/sh
set -e

# A docker-client binary is installed *inside* the web image
# This creates a dependency on the docker-version installed
# on the host. Thus, the web Dockerfile accepts the docker-version
# to install as a parameter, and the built web image is tagged with
# this version number.
docker_version=${1:-1.12.1}
docker_compose_version=${2:-1.8.0}

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

context_dir=.

docker build \
  --build-arg=DOCKER_VERSION=${docker_version} \
  --build-arg=DOCKER_COMPOSE_VERSION=${docker_compose_version} \
  --tag=cyberdojo/${PWD##*/}:${docker_version} \
  --file=${context_dir}/Dockerfile \
  ${context_dir}

