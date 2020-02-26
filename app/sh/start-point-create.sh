#!/bin/bash -Ee
shift # start-point
shift # create
readonly IMAGE_NAME="${1}"
readonly IMAGE_TYPE="${2}"
declare -ar GIT_REPO_URLS="(${@:3})"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo start-point create <name> --custom    <url>...
# cyber-dojo start-point create <name> --exercises <url>...
# cyber-dojo start-point create <name> --languages <url>...
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_use()
{
  local -r MY_NAME=cyber-dojo
  define TEXT <<- EOF

  Use:
  ${MY_NAME} start-point create <name> --custom    <url>...
  ${MY_NAME} start-point create <name> --exercises <url>...
  ${MY_NAME} start-point create <name> --languages <url>...

  Creates a cyber-dojo start-point image named <name>
  containing git clones of the specified git-repo <url>s.
  Its base image will be cyberdojo/starter-base:CYBER_DOJO_START_POINTS_BASE_TAG

  Example 1: local git-repo <url>s

  ${MY_NAME} start-point create \\\\
        eg/first \\\\
          --custom \\\\
            /user/fred/.../yahtzee \\\\
            file:///user/fred/.../fizz_buzz

  Example 2: non-local git-repo <url>

  ${MY_NAME} start-point create \\\\
        eg/second \\\\
          --exercises \\\\
            https://github.com/.../my-exercises

  Example 3: local and non-local git-repo <url>s

  ${MY_NAME} start-point create \\\\
        eg/third \\\\
          --languages \\\\
            /user/fred/.../asm-assert \\\\
            https://github.com/.../my-languages

  Example 4: read git-repo <url>s from a curl'd file

  ${MY_NAME} start-point create \\\\
        eg/fourth \\\\
          --languages \\\\
            \$(curl --silent https://raw.githubusercontent.com/.../url_list/all)

  Example 5: read git-repo <url>s from a local file

  ${MY_NAME} start-point create \\\\
        eg/fifth \\\\
          --languages \\\\
            \$(< my-language-selection.txt)

  cat my-language-selection.txt
  https://github.com/.../java-junit
  https://github.com/.../javascript-jasmine
  https://github.com/.../python-pytest
  https://github.com/.../ruby-minitest

EOF
  printf "${TEXT}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
define()
{
  o=;
  while IFS="\n" read -r a
  do
    o="$o$a"'
';
  done
  eval "$1=\$o"
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

CONTEXT_DIR=''

prepare_context_dir()
{
  CONTEXT_DIR=$(mktemp -d)
  trap remove_context_dir EXIT
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

remove_context_dir()
{
  rm -rf "${CONTEXT_DIR}" > /dev/null
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

git_clone_urls_into_context_dir()
{
  for url in "${GIT_REPO_URLS[@]}"; do
    git_clone_one_url_into_context_dir "${url}"
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Two or more git-repo-urls could have the same repo name
# but be from different repositories.
# So git clone each repo into its own unique directory
# based on a simple incrementing index.
URL_INDEX=0

git_clone_one_url_into_context_dir()
{
  # git-clone directly, from this script, into the
  # context dir before running [docker image build].
  # Viz, run [git clone] on the host rather than wherever
  # the docker daemon is (via a command in the Dockerfile).
  local -r url="${1}"
  cd "${CONTEXT_DIR}"
  local stderr
  if ! stderr="$(git clone --single-branch --branch master --depth 1 "${url}" "${URL_INDEX}" 2>&1)"; then
    local newline=$'\n'
    local msg="ERROR: bad git clone <url>${newline}"
    msg+="${IMAGE_TYPE} ${url}${newline}"
    msg+="${stderr}"
    stderr "${msg}"
    exit 3
  fi

  chmod -R +rX "${URL_INDEX}"
  local -r sha=$(cd ${URL_INDEX} && git rev-parse HEAD)
  echo -e "${IMAGE_TYPE} \t ${url}"
  echo -e "${URL_INDEX} \t ${sha} \t ${url}" >> "${CONTEXT_DIR}/shas.txt"
  rm -rf "${CONTEXT_DIR}/${URL_INDEX}/.git"
  rm -rf "${CONTEXT_DIR}/${URL_INDEX}/docker"
  URL_INDEX=$((URL_INDEX + 1))
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# There is a special case for the GIT_COMMIT_SHA env-var.
# This is needed for cyberdojo/versioner which relies on being
# able to get the SHA out of an 'official' start-point image
# with a :latest tag to create it's .env file.

build_image_from_context_dir()
{
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

image_type()
{
  echo "${IMAGE_TYPE:2}" # '--languages' => 'languages'
}

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
prepare_context_dir
git_clone_urls_into_context_dir
build_image_from_context_dir
