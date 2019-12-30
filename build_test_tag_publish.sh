#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - - -
cat_env_vars()
{
  docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner()
{
  local -r env_vars="${1}"
  local -r sha="$(git_commit_sha)"
  local -r tag="${sha:0:7}"
  local -r fake_sha="CYBER_DOJO_COMMANDER_SHA=${sha}"
  local -r fake_tag="CYBER_DOJO_COMMANDER_TAG=${tag}"
  local -r fake=fake_versioner

  docker rm --force "${fake}" > /dev/null 2>&1 | true
  docker run                  \
    --detach                  \
    --env RELEASE=999.999.999 \
    --env SHA="${sha}"        \
    --name "${fake}"          \
    alpine:latest             \
    sh -c 'mkdir /app' > /dev/null

  echo "${env_vars}" >  /tmp/.env
  echo "${fake_sha}" >> /tmp/.env # replaces earlier entry when exported
  echo "${fake_tag}" >> /tmp/.env # replaces earlier entry when exported

  docker cp /tmp/.env "${fake}:/app/.env"
  docker commit "${fake}" cyberdojo/versioner:latest > /dev/null 2>&1
  docker rm --force "${fake}" > /dev/null 2>&1
  # show it
  docker run --rm -it cyberdojo/versioner:latest sh -c 'cat /app/.env' | tail -n -2
  echo "${fake_sha}:"
  echo "${fake_tag}:"
}

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
  local -r sha=$(docker run --rm $(image_name):latest sh -c 'echo ${SHA}')
  echo "${sha:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_the_image()
{
  local -r image="$(image_name)"
  local -r tag="$(image_tag)"
  docker tag "${image}:latest" "${image}:${tag}"
  echo "${image}:latest tagged to ${image}:${tag}"
  echo "end of fake cyberdojo/versioner:latest's /app/.env is..."
  docker run --rm cyberdojo/versioner:latest sh -c 'tail -n -2 /app/.env'
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
  local -r tag="$(image_tag)"
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push "${image}:latest"
  docker push "${image}:${tag}"
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner "$(cat_env_vars)"
trap 'docker image rm --force cyberdojo/versioner:latest' EXIT
build_image
tag_the_image
on_ci_prepare_saver_volume_mount_dir
if [ "${1}" != '--no-test' ]; then
  "${ROOT_DIR}/test/sh/run.sh"
fi
on_ci_publish_tagged_images
