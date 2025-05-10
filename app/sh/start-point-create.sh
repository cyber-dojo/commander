#!/usr/bin/env bash
set -Eeu

shift                                # start-point
shift                                # create
readonly TMP_IMAGE_NAME=cyberdojo/temporary_start_points
readonly IMAGE_NAME="${1:-}"         # cyberdojo/languages-start-points
readonly IMAGE_TYPE="${2:-}"         # --languages
readonly RAND=$(uuidgen)

declare -ar GIT_REPO_URLS="(${@:3})" # <url>...

# Often /tmp cannot be docker volume-mounted, so use ~/tmp
readonly CONTEXT_DIR=$(mktemp -d ~/tmp.cyber-dojo.commander.start-point.build.context-dir.XXXXXX)
remove_tmp_dir() { rm -rf "${CONTEXT_DIR}" > /dev/null; }
trap remove_tmp_dir EXIT

show_use()
{
  cat <<-'EOF'

  Use:
    cyber-dojo start-point create <name> --custom    <url>...
    cyber-dojo start-point create <name> --exercises <url>...
    cyber-dojo start-point create <name> --languages <url>...

  Creates a cyber-dojo start-point image named <name>
  containing git clones of the specified git-repo <url>s.
  Its base image will be CYBER_DOJO_START_POINTS_BASE_IMAGE:CYBER_DOJO_START_POINTS_BASE_TAG
  <url> can be a plain git-repo url
        Eg https://github.com/cyber-dojo-start-points/gcc-assert
  <url> can be prefixed with a 7-character tag.
        This will git checkout the tag after the git clone.
        Eg 7686e9d@https://github.com/cyber-dojo-start-points/gcc-assert

  Example 1: non local tagged <url>

    cyber-dojo start-point create eg/first \
        --languages 384f486@https://github.com/cyber-dojo-start-points/java-junit

  Example 2: read tagged git-repo <url>s from a local file

    cyber-dojo start-point create eg/second \
        --languages $(< my-language-selection.txt)

    cat my-language-selection.txt
    384f486@https://github.com/cyber-dojo-start-points/java-junit
    cfbd925@https://github.com/cyber-dojo-start-points/javascript-jasmine
    c14a87e@https://github.com/cyber-dojo-start-points/python-pytest
    8fe0d11@https://github.com/cyber-dojo-start-points/ruby-minitest

  Example 3: read tagged git-repo <url>s from a curl'd file

    ORG=https://raw.githubusercontent.com/cyber-dojo
    REPO=languages-start-points

    cyber-dojo start-point create eg/third \
        --languages $(curl --silent ${ORG}/${REPO}/main/git_repo_urls.tagged)

EOF
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_show_use()
{
  if [ -z "${1:-}" ] || [ "${1:-}" = '-h' ] || [ "${1:-}" = '--help' ]; then
    show_use
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed()
{
  for tool in "$@"; do
    if ! installed "${tool}" ; then
      stderr "ERROR: ${tool} is not installed!"
      exit 42
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
installed()
{
  local -r tool="${1}"
  if hash "${tool}" 2> /dev/null; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_if_bad_args()
{
  local -r args="${@:1}"
  set +e
  docker container run --entrypoint="" --rm $(base_image_name) \
    bash -c "ruby /app/src/from_script/bad_args.rb ${args}"
  local -r status=$?
  set -e
  if [ "${status}" != '0' ]; then
    exit "${status}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
git_clone_tagged_urls_into_context_dir()
{
  # Two or more git-repo-urls could have the same repo name but be from different repositories.
  # So git clone each repo into its own unique directory based on a simple incrementing index.
  for i in "${!GIT_REPO_URLS[@]}"; do
    git_clone_one_tagged_url_into_context_dir "${GIT_REPO_URLS[$i]}" "${i}"
  done
  echo -e "$(image_type)" > "${CONTEXT_DIR}/image.type"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
git_clone_one_tagged_url_into_context_dir()
{
  # Run [git clone] directly, on the host, from this script, into the context dir
  local -r url="${1}"          # bbd75a1@https://github.com/cyber-dojo-languages/gcc-assert
  local -r url_index="${2}"    # 0

  if [ "${url:7:1}" == "@" ]; then
    local -r detagged_url="${url:8}"  # "https://github.com/cyber-dojo-languages/gcc-assert"
    local -r tag="${url:0:7}"         # "bbd75a1"
  else
    local -r detagged_url="${url}"    # "https://github.com/cyber-dojo-languages/gcc-assert"
    local -r tag=""                   # ""
  fi

  cd "${CONTEXT_DIR}"
  local output
  if ! output="$(git clone --single-branch --branch master "${detagged_url}" "${url_index}" 2>&1)"; then
    if ! output="$(git clone --single-branch --branch main "${detagged_url}" "${url_index}" 2>&1)"; then
      stderr "ERROR: bad git clone <url>"
      stderr "${IMAGE_TYPE} ${detagged_url}"
      stderr "${output}"
      exit 3
    fi
  fi
  echo "git clone ${detagged_url}"

  cd "${CONTEXT_DIR}/${url_index}"
  if [ "${tag}" != "" ]; then
    echo "git checkout ${tag}"
    if ! output=$(git checkout "${tag}" 2>&1); then
      stderr "ERROR: git checkout ${tag}"
      stderr "${IMAGE_TYPE}"
      stderr "${output}"
      exit 3
    fi
  fi

  local -r sha="$(git rev-parse HEAD)"
  echo -e "${IMAGE_TYPE} \t ${url}"
  echo -e "${url_index} \t ${sha} \t ${url}" >> "${CONTEXT_DIR}/shas.txt"
  rm -rf "${CONTEXT_DIR}/${url_index}/.git"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
build_image_from_context_dir()
{
  # There is a special case for the GIT_COMMIT_SHA env-var.
  # This is needed for cyberdojo/versioner which relies on being
  # able to get the SHA out of an 'official' start-point image
  # with a :latest tag to create it's .env file.
  {
    echo "FROM $(base_image_name)"
    echo "LABEL org.cyber-dojo.start-point=$(image_type)"
    echo "COPY . /app/repos"
    echo "ENV IMAGE_TYPE=$(image_type)"
    if [ -n "${GIT_COMMIT_SHA:-}" ]; then
      echo "ENV SHA=${GIT_COMMIT_SHA}"
    fi
    echo "ENV BASE_IMAGE=$(base_image_name)"
    echo "ENV PORT=$(image_port_number)"
    echo 'ENTRYPOINT [ "/sbin/tini", "-g", "--" ]'
    echo 'CMD [ "./up.sh" ]'
  } > "${CONTEXT_DIR}/Dockerfile"

  echo "Dockerfile" > "${CONTEXT_DIR}/.dockerignore"

#  echo "XXXXXXXXXXXXXXXXXXXX"
#  echo "Dockerfile for ${TMP_IMAGE_NAME}"
#  cat "${CONTEXT_DIR}/Dockerfile"
#  echo "XXXXXXXXXXXXXXXXXXXX"

  # Note: the following will not return the exit code
  # local -r build_output=$(docker image build ...)
  local build_output
  build_output=$(docker image build \
    --rm                      \
    --tag "${TMP_IMAGE_NAME}" \
    "${CONTEXT_DIR}" 2>&1     \
  )

#  echo "XXXXXXXXXXXXXXXXXXXX"
#  echo "docker image build ... ${TMP_IMAGE_NAME}"
#  echo "${build_output}"
#  echo "XXXXXXXXXXXXXXXXXXXX"

  local -r build_status=$?
  if [ "${build_status}" != 0 ]; then
    # Should never happen...
    stderr "${build_output}"
    exit "${build_status}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
tag_clean_image_else_exit_non_zero()
{
  # /app/src/from_script/check_all.rb is in $(base_image_name)
  # Note there is no --rm flag in this 'docker container run'
  # because we need to do a subsequent 'docker inspect'
  local -r check_output=$(docker container run \
    --entrypoint=""                   \
    --name="${RAND}"                  \
    --tty                             \
    "${TMP_IMAGE_NAME}"               \
    ruby                              \
    /app/src/from_script/check_all.rb \
    /app/repos                        \
    "$(image_type)" 2>&1              \
  )

  # Now get the exit code of check_all.rb; _not_ the exit code of the 'docker container run'
  local -r check_status="$(docker inspect "${RAND}" --format='{{.State.ExitCode}}')"
  docker container rm --force "${RAND}" &> /dev/null

#  echo "XXXXXXXXXXXXXXXXXXXX"
#  echo "check_output"
#  echo "${check_output}"
#  echo "XXXXXXXXXXXXXXXXXXXX"

#  echo "XXXXXXXXXXXXXXXXXXXX"
#  echo "contents of check_all.rb"
#  docker container run --rm --entrypoint="" --tty "${TMP_IMAGE_NAME}" bash -c "cat /app/src/from_script/check_all.rb"
#  echo "XXXXXXXXXXXXXXXXXXXX"

  if [ "${check_status}" == 0 ]; then
    docker image tag "${TMP_IMAGE_NAME}" "${IMAGE_NAME}" &> /dev/null
    docker image rm --force "${TMP_IMAGE_NAME}"          &> /dev/null
    echo "Successfully built ${IMAGE_NAME}"
  else
    docker image rm --force "${TMP_IMAGE_NAME}"          &> /dev/null
    stderr "${check_output}"
    exit "${check_status}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
stderr()
{
  local -r message="${1}"
  >&2 echo "${message}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
base_image_name()
{
  # The uppercase names in this are replaced by their
  # env-var values by the cat-start-point-create.sh script.
  # Note: Can't add @sha256:CYBER_DOJO_START_POINTS_BASE_DIGEST here as it breaks start-points-base tests
  echo CYBER_DOJO_START_POINTS_BASE_IMAGE:CYBER_DOJO_START_POINTS_BASE_TAG
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image_type()
{
  echo "${IMAGE_TYPE:2}" # '--languages' => 'languages'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image_port_number()
{
  # The uppercase names in this are replaced by their
  # env-var values by the cat-start-point-create.sh script.
  case "$(image_type)" in
       custom) echo CYBER_DOJO_CUSTOM_START_POINTS_PORT;;
    exercises) echo CYBER_DOJO_EXERCISES_START_POINTS_PORT;;
    languages) echo CYBER_DOJO_LANGUAGES_START_POINTS_PORT;;
  esac
}

#==========================================================

exit_zero_if_show_use "${@}"
exit_non_zero_unless_installed docker git
exit_non_zero_if_bad_args "${@}"
git_clone_tagged_urls_into_context_dir
build_image_from_context_dir
tag_clean_image_else_exit_non_zero
