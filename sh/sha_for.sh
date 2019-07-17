#!/bin/bash
set -e

sha_for()
{
  local name="${1}"
  local image=cyberdojo/${name}:latest

  case "${name}" in
    starter-base)
      docker run --rm -i ${image} sh -c  'echo -n ${BASE_SHA}' ;;
    *)
      docker run --rm ${image} sh -c 'echo -n ${SHA}' ;;
  esac
}

if [ -n "${1}" ]; then
  sha_for "${1}"
fi
