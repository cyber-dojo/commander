#!/bin/bash
set -e
shift # start-point
shift # create

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cyber-dojo start-point create <name> --custom    <url> ...
# cyber-dojo start-point create <name> --exercises <url> ...
# cyber-dojo start-point create <name> --languages <url> ...
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RED=$(tput -Txterm setaf 1)
GREEN=$(tput -Txterm setaf 2)
BOLD=$(tput -Txterm bold)
RS='\033[0m' # NoColour

error()
{
  >&2 echo -e "${RED}ERROR: ${2}${RS}"
  exit "${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_non_zero_unless_git_installed()
{
  if ! hash git 2> /dev/null; then
    error 1 'git is not installed!'
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

readonly IMAGE_NAME="${1}"
readonly IMAGE_TYPE="${2}"
declare -ar GIT_REPO_URLS="(${@:3})"

# - - - - - - - - - - - -

exit_zero_if_show_use()
{
  if [ -z "${1}" ] || [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
    show_use
    exit 0
  fi
}

# - - - - - - - - - - - -

define()
{
  o=;
  while IFS="\n" read -r a; do o="$o$a"'
';
  done
  eval "$1=\$o"
}

show_use()
{
  local -r MY_NAME=cyber-dojo
  define TEXT <<- EOF

  Use:
  ${BOLD}${MY_NAME} start-point create${RS} <name> ${BOLD}--custom${RS}    <url> ...
  ${BOLD}${MY_NAME} start-point create${RS} <name> ${BOLD}--exercises${RS} <url> ...
  ${BOLD}${MY_NAME} start-point create${RS} <name> ${BOLD}--languages${RS} <url> ...

  Creates a cyber-dojo start-point image named <name>
  Its base image will be ${BOLD}cyberdojo/starter-base:STARTER_BASE_TAG${RS}
  It will contain git clones of all the specified git-repo <url>s

  Example 1: local git-repo urls

  ${GREEN}${MY_NAME} start-point create \\\\
        eg/first \\\\
          --custom \\\\
            /user/fred/.../yahtzee \\\\
            /user/fred/.../bowling_game.git \\\\
            file:///user/fred/.../fizz_buzz \\\\
            file:///user/fred/.../game_of_life.git${RS}

  Example 2: non-local git-repo <url>

  ${GREEN}${MY_NAME} start-point create \\\\
        eg/second \\\\
          --exercises \\\\
            https://github.com/.../my-exercises.git${RS}

  Example 3: local and non-local git-repo <url>s

  ${GREEN}${MY_NAME} start-point create \\\\
        eg/third \\\\
          --languages \\\\
            /user/fred/.../asm-assert \\\\
            https://github.com/.../my-languages.git${RS}

  Example 4: read git-repo <url>s from a curl'd file

  ${GREEN}${MY_NAME} start-point create \\\\
        eg/fourth \\\\
          --languages \\\\
            \$(curl --silent https://raw.githubusercontent.com/.../url_list/all)${RS}

  Example 5: read git-repo <url>s from a local file

  ${GREEN}${MY_NAME} start-point create \\\\
        eg/fifth \\\\
          --languages \\\\
            \$(< my-language-selection.txt)${RS}

  ${GREEN}cat my-language-selection.txt${RS}
  https://github.com/.../java-junit.git
  https://github.com/.../javascript-jasmine.git
  https://github.com/.../python-pytest.git
  https://github.com/.../ruby-minitest.git

EOF
  echo -e "${TEXT}"
}

# - - - - - - - - - - - -

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

# - - - - - - - - - - - -

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
    local msg="bad git clone <url>${newline}"
    msg+="${IMAGE_TYPE} ${url}${newline}"
    msg+="${stderr}"
    error 3 "${msg}"
  fi

  chmod -R +rX "${URL_INDEX}"
  local -r sha=$(cd ${URL_INDEX} && git rev-parse HEAD)
  echo -e "${IMAGE_TYPE} \t ${url}"
  echo -e "${URL_INDEX} \t ${sha} \t ${url}" >> "${CONTEXT_DIR}/shas.txt"
  rm -rf "${CONTEXT_DIR}/${URL_INDEX}/.git"
  rm -rf "${CONTEXT_DIR}/${URL_INDEX}/docker"
  # Two or more git-repo-urls could have the same repo name
  # but be from different repositories.
  # So git clone each repo into its own unique directory
  # based on a simple incrementing index.
  URL_INDEX=$((URL_INDEX + 1))
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

build_image_from_context_dir()
{
  case "$(image_type)" in
       'custom') PORT=4526;;
    'exercises') PORT=4525;;
    'languages') PORT=4524;;
  esac

  local env_vars="PORT=${PORT} IMAGE_TYPE=$(image_type)"
  if [ -n "${SHA}" ]; then
    env_vars="${env_vars} SHA=${SHA}"
  fi
  {
    echo "FROM $(base_image_name)"
    echo "LABEL org.cyber-dojo.start-point=$(image_type)"
    echo "COPY . /app/repos"
    echo "RUN /app/src/from_script/check_all.rb /app/repos $(image_type)"
    echo "ENV ${env_vars}"
    echo "EXPOSE ${PORT}"
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
    #   2 Step 1/N : FROM cyberdojo/starter-base:...
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
      | grep --invert-match '\-\-\-'                           \
      | grep --invert-match 'Step'                             \
      | grep --invert-match 'Removing intermediate container'  \
      | >&2 grep --invert-match "The command '/bin/sh -c"      \
      || :
    local -r last_line="${output##*$'\n'}"
    local -r last_word="${last_line##* }"
    docker system prune --force > /dev/null
    exit "${last_word}" # eg 16
  else
    echo -e "${GREEN}Successfully built ${IMAGE_NAME}${RS}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

base_image_name()
{
  # The uppercase-tag in this replaced by the actual tag for the
  # specified/defaulted RELEASE by the cat-start-point-create.sh script.
  echo 'cyberdojo/starter-base:STARTER_BASE_TAG'
}

image_type()
{
  echo "${IMAGE_TYPE:2}" # '--languages' => 'languages'
}

#==========================================================

exit_zero_if_show_use "${@}"
exit_non_zero_if_bad_args "${@}"
exit_non_zero_unless_git_installed
prepare_context_dir
git_clone_urls_into_context_dir
build_image_from_context_dir
