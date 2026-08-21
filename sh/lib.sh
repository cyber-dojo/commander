#!/usr/bin/env bash
set -Eeu

on_ci()
{
  [ "${CI:-}" == true ]
}

echo_stderr()
{
  local -r message="${1}"
  >&2 echo "${message}"
}

exit_non_zero()
{
  exit 42
}

on_Mac()
{
  # detect OS from bash: https://stackoverflow.com/questions/394230
  [[ "${OSTYPE:-}" == "darwin"* ]]
}

# Keeps :latest, which image_tag and local tooling read, and the tag just
# built. Every older tag goes, and an earlier build whose last tag was one of
# those goes with it, so local builds stop accumulating images.
remove_old_images()
{
  local -r tag="${1}"
  local -r name="$(image_name)"
  echo Removing old images
  # grep exits non-zero when the machine holds no commander image, eg one whose
  # images have just been cleared, so an empty list must not end the build.
  local tagged_name
  for tagged_name in $(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^${name}:" || true)
  do
    if [ "${tagged_name}" != "${name}:latest" ] \
    && [ "${tagged_name}" != "${name}:${tag}" ]; then
      # Removing by name:tag untags, so this succeeds even while a container
      # references the image, leaving it dangling until that container goes.
      docker image rm --force "${tagged_name}" || echo "  skipped ${tagged_name} (in use)"
    fi
  done
}
