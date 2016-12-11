#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_compose_version=${1:-1.8.1}

context_dir=${my_dir}

docker build \
  --build-arg=DOCKER_COMPOSE_VERSION=${docker_compose_version} \
  --tag=cyberdojo/commander \
  --file=${context_dir}/Dockerfile \
  ${context_dir}

