#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
build_fake_versioner_image()
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
    --build-arg SHA="${fake_sha}" \
    --build-arg RELEASE=999.999.999 \
    --tag "${fake_image}" \
    "${tmp_dir}"

  rm -rf "${tmp_dir}"

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
