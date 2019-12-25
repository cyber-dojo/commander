#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image()
{
  docker build \
    --build-arg COMMIT_SHA="$(git_commit_sha)" \
    --file="${ROOT_DIR}/app/Dockerfile" \
    --tag=$(image_name) \
    "${ROOT_DIR}/app"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${ROOT_DIR}" && git rev-parse HEAD)
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_prepare_saver_volume_mount_dir()
{
  if on_ci; then
    local -r dir=/cyber-dojo
    sudo mkdir -p "${dir}"
    sudo chown 19663:65533 "${dir}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo cyberdojo/commander
}


# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r tag=$(docker run --rm $(image_name):latest sh -c 'echo ${SHA}')
  echo "${tag:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_the_image()
{
  local -r image="$(image_name)"
  local -r tag="$(image_tag)"
  local -r cmd="docker tag ${image}:latest ${image}:${tag}"
  eval ${cmd}
  echo "${cmd}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  local -r image="$(image_name)"
  local -r tag="$(image_sha)"
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push ${image}:latest
  docker push ${image}:${tag}
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_image
on_ci_prepare_saver_volume_mount_dir
if [ "${1}" != '--no-test' ]; then
  "${ROOT_DIR}/test/sh/run.sh"
fi
tag_the_image
on_ci_publish_tagged_images
