#!/usr/bin/env bash
set -Eeu

root_dir() { git rev-parse --show-toplevel; }
export -f root_dir

source "$(root_dir)/sh"/config.sh
source "$(root_dir)/sh"/exit_non_zero_unless_installed.sh
source "$(root_dir)/sh"/lib.sh

exit_non_zero_unless_installed docker

docker build \
  --build-arg COMMIT_SHA="$(git_commit_sha)" \
  --file="$(root_dir)/Dockerfile" \
  --tag="$(image_name)" \
  "$(root_dir)"

docker tag "$(image_name):latest" "$(image_name):$(image_tag)"
echo "$(image_name):latest tagged to $(image_name):$(image_tag)"
