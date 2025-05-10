#!/usr/bin/env bash
set -Eeu

root_dir() { git rev-parse --show-toplevel; }
export -f root_dir

source "$(root_dir)/sh"/build_fake_versioner_image.sh
source "$(root_dir)/sh"/config.sh
source "$(root_dir)/sh"/lib.sh
source "$(root_dir)/sh"/on_ci_prepare_saver_volume_mount_dir.sh
source "$(root_dir)/sh"/pull_start_points_base_image.sh

build_fake_versioner_image
trap 'docker image rm --force cyberdojo/versioner:latest' EXIT
on_ci_prepare_saver_volume_mount_dir
pull_start_points_base_image

"$(root_dir)/test/sh/run.sh"
