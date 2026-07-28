#!/usr/bin/env bash
set -Eeu

# The saver and the spooler each bind-mount a host dir (see volumes.yml) and
# each refuses to start unless its dir exists and is owned by its own user.
# Create both before any [cyber-dojo up].
on_ci_prepare_volume_mount_dirs()
{
  if on_ci; then
    prepare_volume_mount_dir /cyber-dojo 19663:65533
    prepare_volume_mount_dir /cyber-dojo-spooler 19664:65533
  fi
}

# Creates one bind-mount dir owned by uid:gid of the service that writes to it.
prepare_volume_mount_dir()
{
  local -r dir="${1}"
  local -r owner="${2}"
  sudo mkdir -p "${dir}"
  sudo chown "${owner}" "${dir}"
}
