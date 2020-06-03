#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TMP_DIR="$(mktemp -d /tmp/commander.XXXXXXX)"

# - - - - - - - - - - - - - - - - - - - - - - - -
remove_resources()
{
  docker image rm --force cyberdojo/versioner:latest
  rm -rf "${TMP_DIR}"
}
trap remove_resources EXIT

# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner()
{
  # Build a fake cyberdojo/versioner:latest image that serves
  # COMMANDER SHA/TAG values for the local repo.
  # This breaks the [commander <-> versioner] circular dependency.
  # You can edit this function to insert fake SHA/TAG values for any service.
  # See for example:
  # https://github.com/cyber-dojo/commander/blob/b205967be70f11fb80f02a123a36287b66d98bd3/build_test_tag_publish.sh#L29

  local -r sha_var_name=CYBER_DOJO_COMMANDER_SHA
  local -r tag_var_name=CYBER_DOJO_COMMANDER_TAG

  local -r fake_sha="$(git_commit_sha)"
  local -r fake_tag="${fake_sha:0:7}"

  local env_vars="$(docker run --rm cyberdojo/versioner:latest)"
  env_vars=$(replace_with "${env_vars}" "${sha_var_name}" "${fake_sha}")
  env_vars=$(replace_with "${env_vars}" "${tag_var_name}" "${fake_tag}")

  echo "${env_vars}" > ${TMP_DIR}/.env

  local -r fake_image=cyberdojo/versioner:latest
  {
    echo 'FROM alpine:latest'
    echo 'COPY . /app'
    echo 'ARG SHA'
    echo 'ENV SHA=${SHA}'
    echo 'ARG RELEASE'
    echo 'ENV RELEASE=${RELEASE}'
    echo 'ENTRYPOINT [ "cat", "/app/.env" ]'
  } > ${TMP_DIR}/Dockerfile
  docker build \
    --build-arg SHA="${fake_sha}" \
    --build-arg RELEASE=999.999.999 \
    --tag "${fake_image}" \
    "${TMP_DIR}"

  echo "Checking fake ${fake_image}"

  expected="${sha_var_name}=${fake_sha}"
  actual=$(docker run --rm "${fake_image}" | grep "${sha_var_name}")
  assert_equal "${expected}" "${actual}"

  expected="${tag_var_name}=${fake_tag}"
  actual=$(docker run --rm "${fake_image}" | grep "${tag_var_name}")
  assert_equal "${expected}" "${actual}"

  expected='RELEASE=999.999.999'
  actual=RELEASE=$(docker run --entrypoint "" --rm "${fake_image}" sh -c 'echo ${RELEASE}')
  assert_equal "${expected}" "${actual}"

  expected="SHA=${fake_sha}"
  actual=SHA=$(docker run --entrypoint "" --rm "${fake_image}" sh -c 'echo ${SHA}')
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
  echo "expected: '${expected}'"
  echo "  actual: '${actual}'"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: assert_equal failed"
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
}

# - - - - - - - - - - - - - - - - - - - - - - - -
pull_start_points_base_image()
{
  # To prevent stdout pull messages interfering with tests
  local -r image=$(docker run --rm --entrypoint="" cyberdojo/versioner:latest \
    sh -c 'export $(cat /app/.env) && echo ${CYBER_DOJO_START_POINTS_BASE_IMAGE}')
  local -r   tag=$(docker run --rm --entrypoint="" cyberdojo/versioner:latest \
    sh -c 'export $(cat /app/.env) && echo ${CYBER_DOJO_START_POINTS_BASE_TAG}')
  docker pull ${image}:${tag}
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push "$(image_name):latest"
  docker push "$(image_name):$(image_tag)"
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner
build_image
tag_the_image
on_ci_prepare_saver_volume_mount_dir
pull_start_points_base_image
if [ "${1}" == --build-only ] || [ "${1}" == -bo ]; then
  exit 0
fi
on_ci_publish_tagged_images
