#!/bin/bash -Ee
# [cyber-dojo] start-point create cyberdojo/languages-start-points --languages <url>...

shift                                # start-point
shift                                # create
readonly IMAGE_NAME="${1}"           # cyberdojo/languages-start-points
readonly IMAGE_TYPE="${2}"           # --languages
declare -ar GIT_REPO_URLS="(${@:3})" # <url>...

# In Docker Toolbox /tmp cannot be docker volume-mounted, so ~/tmp
readonly CONTEXT_DIR=$(mktemp -d ~/tmp.cyber-dojo.commander.start-point.build.context-dir.XXX)
remove_tmp_dir()
{
  rm -rf "${CONTEXT_DIR}" > /dev/null
}
trap remove_tmp_dir EXIT

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo start-point create <name> --custom    <tag-url>...
# cyber-dojo start-point create <name> --exercises <tag-url>...
# cyber-dojo start-point create <name> --languages <tag-url>...
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
show_use()
{
  local -r MY_NAME=cyber-dojo
  cat <<- EOF

  Use:
  ${MY_NAME} start-point create <name> --languages <url>...

  Creates a cyber-dojo start-point image named <name>
  containing git clones of the specified git-repo <url>s.
  Its base image will be CYBER_DOJO_START_POINTS_BASE_IMAGE:CYBER_DOJO_START_POINTS_BASE_TAG
  <url> can be a plain git-repo url
        Eg https://github.com/cyber-dojo-start-points/gcc-assert
  <url> can be prefixed with a 7-character tag.
        This will git checkout the tag after the git clone.
        Eg 7686e9d@https://github.com/cyber-dojo-start-points/gcc-assert

  Example 1: non local tagged <url>
    ${MY_NAME} start-point create \\
      eg/first \\
        --languages \\
          384f486@https://github.com/cyber-dojo-start-points/java-junit

  Example 2: read tagged git-repo <url>s from a local file
    ${MY_NAME} start-point create \\
      eg/second \\
        --languages \\
          \$(< my-language-selection.txt)

    cat my-language-selection.txt
    384f486@https://github.com/cyber-dojo-start-points/java-junit
    cfbd925@https://github.com/cyber-dojo-start-points/javascript-jasmine
    c14a87e@https://github.com/cyber-dojo-start-points/python-pytest
    8fe0d11@https://github.com/cyber-dojo-start-points/ruby-minitest

  Example 3: read tagged git-repo <url>s from a curl'd file
    ${MY_NAME} start-point create \\
      eg/third \\
        --languages \\
          \$(curl --silent https://raw.githubusercontent.com/cyber-dojo/languages-start-points/master/start-points/git_repo_urls.all.tagged)

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
exit_non_zero_unless_installed()
{
  if ! installed "${1}" ; then
    stderr 'ERROR: ${1} is not installed!'
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
installed()
{
  if hash "${1}" 2> /dev/null; then
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
  echo "git clone ${detagged_url}"
  if ! output="$(git clone --single-branch --branch master "${detagged_url}" "${url_index}" 2>&1)"; then
    stderr "ERROR: git clone ${detagged_url}"
    stderr "${IMAGE_TYPE}"
    stderr "${output}"
    exit 3
  fi

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
exit_non_zero_unless_installed docker
exit_non_zero_unless_installed git
exit_non_zero_if_bad_args "${@}"
git_clone_tagged_urls_into_context_dir
build_image_from_context_dir
