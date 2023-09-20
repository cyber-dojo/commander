#!/usr/bin/env bash
set -Eeu

pull_start_points_base_image()
{
  # To prevent stdout pull messages interfering with tests
  local -r image=$(docker run --rm --entrypoint="" cyberdojo/versioner:latest \
    sh -c 'export $(cat /app/.env) && echo ${CYBER_DOJO_START_POINTS_BASE_IMAGE}')
  local -r   tag=$(docker run --rm --entrypoint="" cyberdojo/versioner:latest \
    sh -c 'export $(cat /app/.env) && echo ${CYBER_DOJO_START_POINTS_BASE_TAG}')
  docker pull "${image}:${tag}"
}
