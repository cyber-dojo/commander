#!/bin/bash -Ee
# [cyber-dojo] start-point build cyberdojo/languages-start-points --languages <tag-url>...

shift                                # start-point
shift                                # build
readonly IMAGE_NAME="${1}"           # cyberdojo/languages-start-points
readonly IMAGE_TYPE="${2}"           # --languages
declare -ar GIT_REPO_URLS="(${@:3})" # <tag-url>...

# In Docker Toolbox /tmp cannot be docker volume-mounted, so ~/tmp
readonly CONTEXT_DIR=$(mktemp -d ~/tmp.cyber-dojo.commander.start-point.build.context-dir.XXX)
remove_tmp_dir()
{
  rm -rf "${CONTEXT_DIR}" > /dev/null
}
trap remove_tmp_dir EXIT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo start-point build <name> --languages <tag-url>...
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
show_use()
{
  local -r MY_NAME=cyber-dojo
  cat <<- EOF

  Use:
  ${MY_NAME} start-point build <name> --languages <tag-url>...

  Builds a cyber-dojo start-point image named <name>
  containing git clones of the specified git-repo <url>s.
  Its base image will be CYBER_DOJO_START_POINTS_BASE_IMAGE:CYBER_DOJO_START_POINTS_BASE_TAG
  The image_name in each <url>'s start_point/manifest.json file is
  tagged. The tag is the first seven chars of the <tag-url>.

  Example 1: non local <tag-url>

  ${MY_NAME} start-point build \\
        eg/first \\
          --languages \\
            800f67d@https://github.com/.../java-junit

  Example 2: read git-repo <tag-url>s from a local file

  ${MY_NAME} start-point build \\
        eg/second \\
          --languages \\
            \$(< my-language-selection.txt)

  cat my-language-selection.txt
  800f67d@https://github.com/.../java-junit
  055826a@https://github.com/.../javascript-jasmine
  fcacae3@https://github.com/.../python-pytest
  3d7b8ea@https://github.com/.../ruby-minitest

  Example 3: read git-repo <tag-url>s from a curl'd file

  ${MY_NAME} start-point build \\
        eg/third \\
          --languages \\
            \$(curl --silent https://raw.githubusercontent.com/.../start-points/git_repo_urls.all.tagged)

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
exit_non_zero_unless_docker_installed()
{
  if ! hash docker 2> /dev/null; then
    stderr 'ERROR: docker is not installed!'
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_git_installed()
{
  if ! hash git 2> /dev/null; then
    stderr 'ERROR: git is not installed!'
    exit 42
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
git_clone_tagged_urls_into_context_dir()
{
  # Two or more git-repo-urls could have the same repo name
  # but be from different repositories.
  # So git clone each repo into its own unique directory
  # based on a simple incrementing index.
  for i in "${!GIT_REPO_URLS[@]}"; do
    git_clone_one_tagged_url_into_context_dir "${GIT_REPO_URLS[$i]}" "${i}"
  done
  echo -e "$(image_type)" > "${CONTEXT_DIR}/image.type"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
git_clone_one_tagged_url_into_context_dir()
{
  # git-clone directly, from this script, into the
  # context dir before running [docker image build].
  # Run [git clone] on the _host_ rather than wherever
  # the docker daemon is (via a command in the Dockerfile).
  local output
  local -r tagged_url="${1}"       # bbd75a1@https://github.com/cyber-dojo-languages/gcc-assert
  local -r url_index="${2}"        # 0
  local -r tag="${tagged_url:0:7}" # bbd75a1
  local -r url="${tagged_url:8}"   # https://github.com/cyber-dojo-languages/gcc-assert

  cd "${CONTEXT_DIR}"
  echo "Git cloning ${url}"
  if ! output="$(git clone --single-branch --branch master "${url}" "${url_index}" 2>&1)"
  then
    stderr "ERROR: git clone ... ${url}"
    stderr "${IMAGE_TYPE}"
    stderr "${output}"
    exit 3
  fi

  cd "${CONTEXT_DIR}/${url_index}"
  if ! output=$(git checkout "${tag}" 2>&1)
  then
    stderr "ERROR: git checkout ${tag}"
    stderr "${IMAGE_TYPE}"
    stderr "${output}"
    exit 3
  fi

  local -r sha="$(git rev-parse HEAD)"
  echo -e "${IMAGE_TYPE} \t ${url}"
  echo -e "${url_index} \t ${sha} \t ${url}" >> "${CONTEXT_DIR}/shas.txt"
  rm -rf "${CONTEXT_DIR}/${url_index}/.git"
  rm -rf "${CONTEXT_DIR}/${url_index}/docker"
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
        --compress                 \
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
  # env-var values by the cat-start-point-build.sh script.
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
  # env-var values by the cat-start-point-build.sh script.
  case "$(image_type)" in
       custom) echo CYBER_DOJO_CUSTOM_START_POINTS_PORT;;
    exercises) echo CYBER_DOJO_EXERCISES_START_POINTS_PORT;;
    languages) echo CYBER_DOJO_LANGUAGES_START_POINTS_PORT;;
  esac
}

#==========================================================

exit_zero_if_show_use "${@}"
exit_non_zero_unless_docker_installed
exit_non_zero_unless_git_installed
exit_non_zero_if_bad_args "${@}"
git_clone_tagged_urls_into_context_dir
build_image_from_context_dir
