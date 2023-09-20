#!/usr/bin/env bash
set -Eeu

build_image()
{
  docker build \
    --build-arg COMMIT_SHA="$(git_commit_sha)" \
    --file="$(root_dir)/app/Dockerfile" \
    --tag="$(image_name)" \
    "$(root_dir)/app"
}
