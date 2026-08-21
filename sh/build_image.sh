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

# Captured once: image_tag runs a container to read SHA out of the image.
readonly TAG="$(image_tag)"

docker tag "$(image_name):latest" "$(image_name):${TAG}"
echo "$(image_name):latest tagged to $(image_name):${TAG}"

# After tagging, so removing an earlier build's tags takes its last tag with
# them and the image itself goes, rather than being left dangling when :latest
# moves to this build.
remove_old_images "${TAG}"
