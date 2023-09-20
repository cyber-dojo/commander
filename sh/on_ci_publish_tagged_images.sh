#!/usr/bin/env bash
set -Eeu

on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
  else
    echo 'on CI so publishing tagged images'
    echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
    docker push "$(image_name):latest"
    docker push "$(image_name):$(image_tag)"
    docker logout
  fi
}
