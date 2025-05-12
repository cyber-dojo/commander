#!/usr/bin/env bash
set -Eeu

debug_spb()
{
  # For debugging; there is a circular dependency on start-points-base.
  # If you have a locally built start-points-base image that exists in dockerhub
  # but is not yet served from cyberdojo/versioner:latest then
  # make this function return true, and set spb_fake_sha to its commit-sha below.

  return 1 # false
  # return 0 # true
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner_image()
{
  # Build a fake cyberdojo/versioner:latest image that serves SHA/TAG values for local repo(s).
  # This breaks the [commander <-> versioner] circular dependency.

  local env_vars="$(docker run --rm cyberdojo/versioner:latest 2> /dev/null)"

  local -r comm_sha_var_name=CYBER_DOJO_COMMANDER_SHA
  local -r comm_tag_var_name=CYBER_DOJO_COMMANDER_TAG
  local -r comm_fake_sha="$(git_commit_sha)"
  local -r comm_fake_tag="${comm_fake_sha:0:7}"
  env_vars=$(replace_with "${env_vars}" "${comm_sha_var_name}" "${comm_fake_sha}")
  env_vars=$(replace_with "${env_vars}" "${comm_tag_var_name}" "${comm_fake_tag}")

  if debug_spb; then
    local -r spb_sha_var_name=CYBER_DOJO_START_POINTS_BASE_SHA
    local -r spb_tag_var_name=CYBER_DOJO_START_POINTS_BASE_TAG
    local -r spb_fake_sha="749c3a2c891c6c43f48d980526e716bbce50ed48"
    local -r spb_fake_tag="${spb_fake_sha:0:7}"
    env_vars=$(replace_with "${env_vars}" "${spb_sha_var_name}" "${spb_fake_sha}")
    env_vars=$(replace_with "${env_vars}" "${spb_tag_var_name}" "${spb_fake_tag}")
  fi

  local -r tmp_dir="$(mktemp -d /tmp/commander.XXXXXXX)"

  echo "${env_vars}" > ${tmp_dir}/.env

  local -r fake_image=cyberdojo/versioner:latest
  {
    echo 'FROM alpine:latest'
    echo 'COPY . /app'
    echo 'ARG SHA'
    echo 'ENV SHA=${SHA}'
    echo 'ARG RELEASE'
    echo 'ENV RELEASE=${RELEASE}'
    echo 'ENTRYPOINT [ "cat", "/app/.env" ]'
  } > ${tmp_dir}/Dockerfile

  docker build \
    --build-arg SHA="${comm_fake_sha}" \
    --build-arg RELEASE=999.999.999 \
    --tag "${fake_image}" \
    "${tmp_dir}"

  rm -rf "${tmp_dir}"

  echo "Checking fake ${fake_image}"

  expected="${comm_sha_var_name}=${comm_fake_sha}"
  actual=$(docker run --rm "${fake_image}" | grep "${comm_sha_var_name}")
  assert_equal "${expected}" "${actual}"

  expected="${comm_tag_var_name}=${comm_fake_tag}"
  actual=$(docker run --rm "${fake_image}" | grep "${comm_tag_var_name}")
  assert_equal "${expected}" "${actual}"

  if debug_spb; then
    expected="${spb_sha_var_name}=${spb_fake_sha}"
    actual=$(docker run --rm "${fake_image}" | grep "${spb_sha_var_name}")
    assert_equal "${expected}" "${actual}"

    expected="${spb_tag_var_name}=${spb_fake_tag}"
    actual=$(docker run --rm "${fake_image}" | grep "${spb_tag_var_name}")
    assert_equal "${expected}" "${actual}"
  fi

  expected='RELEASE=999.999.999'
  actual=RELEASE=$(docker run --entrypoint "" --rm "${fake_image}" sh -c 'echo ${RELEASE}')
  assert_equal "${expected}" "${actual}"

  expected="SHA=${comm_fake_sha}"
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
  printf "%s\n%s=%s\n" "${all_except}" "${name}" "${fake_value}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r expected="${1}"
  local -r actual="${2}"
  if [ "${expected}" == "${actual}" ]; then
    echo "${expected}"
  else
    echo "ERROR: assert_equal failed"
    echo "expected: '${expected}'"
    echo "  actual: '${actual}'"
    exit 42
  fi
}
