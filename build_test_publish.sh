#!/usr/bin/env bash
set -Eeu

root_dir() { git rev-parse --show-toplevel; }
export -f root_dir

for script in "$(root_dir)/sh"/*.sh; do
  source "${script}"
done

exit_non_zero_unless_installed docker
build_fake_versioner_image
trap 'docker image rm --force cyberdojo/versioner:latest' EXIT
build_image
tag_the_image
exit_zero_if_build_only
on_ci_prepare_saver_volume_mount_dir
pull_start_points_base_image
run_tests
# on_ci_publish_tagged_images
