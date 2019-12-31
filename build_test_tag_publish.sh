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
  local -r sha_var_name=CYBER_DOJO_COMMANDER_SHA
  local -r tag_var_name=CYBER_DOJO_COMMANDER_TAG

  local -r fake_sha="$(git_commit_sha)"
  local -r fake_tag="${fake_sha:0:7}"

  local env_vars="${1}"
  env_vars=$(replace_with "${env_vars}" "${sha_var_name}" "${fake_sha}")
  env_vars=$(replace_with "${env_vars}" "${tag_var_name}" "${fake_tag}")

  local -r fake_container=fake_versioner
  local -r fake_image=cyberdojo/versioner:latest

  docker rm --force "${fake_container}" > /dev/null 2>&1 | true
  docker run                   \
    --detach                   \
    --env RELEASE=999.999.999  \
    --env SHA="${fake_sha}"    \
    --name "${fake_container}" \
    alpine:latest              \
      sh -c 'mkdir /app' > /dev/null

  echo "${env_vars}" >  /tmp/.env
  docker cp /tmp/.env "${fake_container}:/app/.env"
  docker commit "${fake_container}" "${fake_image}" > /dev/null 2>&1
  docker rm --force "${fake_container}" > /dev/null 2>&1

  # check it
  expected="${sha_var_name}=${fake_sha}"
  actual=$(docker run --rm "${fake_image}" sh -c 'cat /app/.env' | grep "${sha_var_name}")
  assert_equal "${expected}" "${actual}"

  expected="${tag_var_name}=${fake_tag}"
  actual=$(docker run --rm "${fake_image}" sh -c 'cat /app/.env' | grep "${tag_var_name}")
  assert_equal "${expected}" "${actual}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
replace_with()
{
  local -r env_vars="${1}"
  local -r name="${2}"
  local -r fake_value="${3}"
  local -r all_except=$(echo "${env_vars}" | grep --invert-match "${name}")
  printf "${all_except}\n${name}=${fake_value}\n"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r expected="${1}"
  local -r actual="${2}"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR"
    echo "expected:${expected}"
    echo "  actual:${actual}"
    exit 42
  fi
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
trap 'docker image rm --force cyberdojo/versioner:latest' EXIT
build_fake_versioner "$(cat_env_vars)"
build_image
tag_the_image
on_ci_prepare_saver_volume_mount_dir
if [ "${1}" != '--no-test' ]; then
  "${ROOT_DIR}/test/sh/run.sh"
fi
on_ci_publish_tagged_images
