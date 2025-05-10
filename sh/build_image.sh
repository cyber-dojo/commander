#!/usr/bin/env bash
set -Eeu

root_dir() { git rev-parse --show-toplevel; }
export -f root_dir

source "$(root_dir)/sh"/build_fake_versioner_image.sh
#source "$(root_dir)/sh"/build_image.sh
source "$(root_dir)/sh"/config.sh
source "$(root_dir)/sh"/exit_non_zero_unless_installed.sh
#source "$(root_dir)/sh"/exit_zero_if_build_only.sh
#source "$(root_dir)/sh"/lib.sh
#source "$(root_dir)/sh"/on_ci_prepare_saver_volume_mount_dir.sh
#source "$(root_dir)/sh"/pull_start_points_base_image.sh
#source "$(root_dir)/sh"/run_tests.sh
#source "$(root_dir)/sh"/tag_the_image.sh


exit_non_zero_unless_installed docker
build_fake_versioner_image
trap 'docker image rm --force cyberdojo/versioner:latest' EXIT

docker build \
  --build-arg COMMIT_SHA="$(git_commit_sha)" \
  --file="$(root_dir)/Dockerfile" \
  --tag="$(image_name)" \
  "$(root_dir)"

docker tag "$(image_name):latest" "$(image_name):$(image_tag)"
echo "$(image_name):latest tagged to $(image_name):$(image_tag)"

#build_image
#tag_the_image
#exit_zero_if_build_only $@
#on_ci_prepare_saver_volume_mount_dir
#pull_start_points_base_image
#run_tests
