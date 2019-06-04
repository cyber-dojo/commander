#!/bin/bash
set -e

sha_for()
{
  local name="${1}"
  local image=cyberdojo/${name}:latest

  case "${name}" in
    grafana|prometheus)
      local pid=$(docker run -d cyberdojo/${name}:latest)
      docker exec ${pid} sh -c 'echo -n ${SHA}'
      docker rm ${pid} --force > /dev/null ;;
    starter-base)
      docker run --rm -i ${image} sh -c  'echo -n ${BASE_SHA}' ;;
    *)
      docker run --rm ${image} sh -c 'echo -n ${SHA}' ;;
  esac
}

if [ "${1}" != '' ]; then
  sha_for "${1}"
fi
