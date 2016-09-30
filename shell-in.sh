#!/bin/sh

docker_version=$(docker --version | awk '{print $3}' | sed '$s/.$//')

docker run \
  --rm \
  --interactive \
  --tty \
  --user=root \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  cyberdojo/commander:${docker_version} \
  sh

