#!/bin/bash -Ee
shift # start-point
shift # build
readonly IMAGE_NAME="${1}"
readonly IMAGE_TYPE="${2}"
declare -ar IMAGE_NAMES="(${@:3})"
# When running Docker Toolbox /tmp cannot be docker volume-mounted. So ~
readonly CONTEXT_DIR=$(mktemp -d ~/tmp.cyber-dojo.commander.start-point.build.context-dir.XXX)
readonly TMP_DIR=$(mktemp -d ~/tmp.cyber-dojo.commander.start-point.build.XXXXXX)
remove_tmp_dirs()
{
  rm -rf "${TMP_DIR}" > /dev/null
  rm -rf "${CONTEXT_DIR}" > /dev/null
}
trap remove_tmp_dirs EXIT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo start-point build <name> --languages <image>...
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
show_use()
{
  local -r MY_NAME=cyber-dojo
  cat <<- EOF

  Use:
  ${MY_NAME} start-point build <name> --custom    <image>...
  ${MY_NAME} start-point build <name> --exercises <image>...
  ${MY_NAME} start-point build <name> --languages <image>...

  Builds a cyber-dojo start-point image named <name>
  containing start_point/ dirs of the specified <image> names.
  Its base image will be cyberdojo/starter-base:CYBER_DOJO_START_POINTS_BASE_TAG

  Example 1: local git-repo <url>s

  ${MY_NAME} start-point build \\\\
        eg/first \\\\
          --languages \\\\
            cyberdojostartpoints/python_behave

  Example 2: read <image> names from a curl'd file

  ${MY_NAME} start-point build \\\\
        eg/fourth \\\\
          --languages \\\\
            \$(curl --silent https://raw.githubusercontent.com/.../image_list/all)

  Example 3: read <image> names from a local file

  ${MY_NAME} start-point build \\\\
        eg/fifth \\\\
          --languages \\\\
            \$(< my-language-selection.txt)

  cat my-language-selection.txt
  cyberdojostartpoints/java_junit
  cyberdojostartpoints/python_pytest
  cyberdojostartpoints/ruby_minitest

EOF
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_show_use()
{
  if [ -z "${1}" ] || [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
    show_use
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_if_bad_args()
{
  local -r args="${@:1}"
  set +e
  docker container run --rm $(base_image_name) \
    /app/src/from_script/bad_args.rb ${args}
  local -r status=$?
  set -e
  if [ "${status}" != '0' ]; then
    exit "${status}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_git_installed()
{
  if ! hash git 2> /dev/null; then
    stderr 'ERROR: git is not installed!'
    exit 3
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
copy_images_into_context_dir()
{
  # Copy each image's start_point/ into its own unique
  # directory based on a simple incrementing index.
  local -r count="$((${#IMAGE_NAMES[@]}-1))"
  for i in "${!IMAGE_NAMES[@]}"; do
    copy_one_image_into_context_dir "${IMAGE_NAMES[$i]}" "${i}"
  done
  echo -e "$(image_type)" > "${CONTEXT_DIR}/image.type"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
copy_one_image_into_context_dir()
{
  local stderr
  local -r image_name="${1}"
  local -r image_index="${2}"
  local -r cidfile="${TMP_DIR}/${image_index}"
  if ! stderr=$(docker create --cidfile="${cidfile}" "${image_name}" 2>&1); then
    stderr "ERROR: cannot create container from ${image_name}"
    stderr "${stderr}"
    exit 3
  fi
  local -r cid=$(cat "${cidfile}")
  if ! stderr=$(docker cp "${cid}:/start_point/." "${CONTEXT_DIR}/${image_index}" 2>&1); then
    stderr "ERROR: cannot copy start_point/ out of ${image_name}"
    stderr "${stderr}"
    exit 4
  fi
  stderr=$(docker rm --force "${cid}" 2>&1)

  echo -e "${IMAGE_TYPE} \t ${image_name}"
  echo -e "${image_index} \t ${image_name}" >> "${CONTEXT_DIR}/build.shas"
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
    echo "RUN /app/src/from_script/check_all.rb /app/repos $(image_type)"
    echo "ENV IMAGE_TYPE=$(image_type)"
    if [ -n "${GIT_COMMIT_SHA}" ]; then
      echo "ENV SHA=${GIT_COMMIT_SHA}"
    fi
    echo "ENV PORT=$(image_port_number)"
    echo "EXPOSE $(image_port_number)"
    echo 'CMD [ "./up.sh" ]'
  } > "${CONTEXT_DIR}/Dockerfile"
  echo "Dockerfile" > "${CONTEXT_DIR}/.dockerignore"
  local output
  if ! output=$(docker image build \
        --quiet                    \
        --rm                       \
        --tag "${IMAGE_NAME}"      \
        "${CONTEXT_DIR}" 2>&1)
  then
    # We are building FROM an image and we want any diagnostics
    # but we do not want the output from the [docker build] itself.
    # Hence the --quiet option.
    # On a Macbook using Docker-Toolbox stderr looks like this:
    #
    #   1 Sending build context to Docker daemon  185.9kB
    #   2 Step 1/N : FROM cyberdojo/start-points-base:...
    #   3  ---> Running in fe6adeee193c
    #   ...
    #---5 ERROR: no manifest.json files in
    #---6 --custom file:///Users/.../custom_no_manifests
    #   7 The command '/bin/sh -c ...' returned a non-zero code: 16
    #
    # We want only lines 5,6
    # On CircleCI, stderr is not identical so the grep patterns are a little loose.

    echo "${output}" \
      | grep --invert-match 'Sending build context to Docker'  \
      | grep --invert-match 'Step'                             \
      | grep --invert-match '\-\-\-'                           \
      | grep --invert-match 'Removing intermediate container'  \
      | >&2 grep --invert-match "The command '/bin/sh -c"      \
      || :
    local -r last_line="${output##*$'\n'}"
    local -r last_word="${last_line##* }"
    docker system prune --force > /dev/null
    exit "${last_word}" # eg 16
  else
    echo "Successfully built ${IMAGE_NAME}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
stderr()
{
  >&2 echo "${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
base_image_name()
{
  # The uppercase names in this are replaced by their
  # env-var values by the cat-start-point-create.sh script.
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
exit_non_zero_if_bad_args "${@}"
exit_non_zero_unless_git_installed
copy_images_into_context_dir
build_image_from_context_dir
