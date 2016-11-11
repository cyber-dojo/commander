#!/bin/bash

docker run \
  --rm \
  --interactive \
  --tty \
  --user=root \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  cyberdojo/commander \
  sh

