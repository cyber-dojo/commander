#!/bin/sh

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"
docker_version=$(docker --version | awk '{print $3}' | sed '$s/.$//')

cyber_dojo_commander=cyberdojo/commander:${docker_version}

cyber_dojo_hub=cyberdojo
cyber_dojo_root=/usr/src/cyber-dojo

default_start_point_languages=languages
default_start_point_exercises=exercises
default_start_point_custom=custom

# start-points are held off CYBER_DOJO_ROOT/start_points/
# it's important they are not under app so any ruby files they might contain
# are *not* slurped by the rails web server as it starts!
export CYBER_DOJO_START_POINT_LANGUAGES=${default_start_point_languages}
export CYBER_DOJO_START_POINT_EXERCISES=${default_start_point_exercises}
export CYBER_DOJO_START_POINT_CUSTOM=${default_start_point_custom}

# set environment variables required by docker-compose.yml

export CYBER_DOJO_WEB_SERVER=${cyber_dojo_hub}/web:${docker_version}
export CYBER_DOJO_WEB_CONTAINER=cyber-dojo-web
export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER
export CYBER_DOJO_ROOT=${cyber_dojo_root}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_volume() {
  # A previous version of this script detected if /var/www/cyber-dojo/katas
  # existed on the host in which case it assumed an old cyber-dojo server
  # was being upgraded and automatically copied it into the new volume.
  # It doesn't do that any more. If you want to upgrade an older server
  # have a look at test/notes/copy_katas_into_data_container.sh
  docker ps --all | grep -s ${CYBER_DOJO_KATAS_DATA_CONTAINER} > /dev/null
  if [ $? != 0 ]; then
    docker create -v ${CYBER_DOJO_ROOT}/katas \
      --name ${CYBER_DOJO_KATAS_DATA_CONTAINER} \
      cyberdojo/user-base \
      /bin/true
  fi
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo start-point create --git=URL
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

g_cid=''      # if this is not '' then clean_up [docker rm]'s the container
g_vol=''      # if this is not '' then clean_up [docker volume rm]'s the volume

cyber_dojo_start_point_create_git() {
  # TODO: cyber-dojo.rb has already been called to check arguments and handle --help
  local name=$1
  local url=$2
  if start_point_exists ${name}; then
    echo "FAILED: a start-point called ${name} already exists"
  fi
  # 1. make an empty docker volume
  command="docker volume create --name=${name} --label=cyber-dojo-start-point=${url}"
  run "${command}" || clean_up_and_exit_fail "FAILED: check command carefully"
  g_vol=${name}


  # TODO: can I simplify 2. with
  #       g_cid=`docker create ...`

  # 2. mount empty volume inside docker container
  command="docker run
               --detach
               --interactive
               --net=none
               --user=root
               --volume=${name}:/data
               ${cyber_dojo_commander} sh"
  run "${command}" || clean_up_and_exit_fail "${command} failed!?"
  g_cid=`docker ps --quiet --latest`


  # 3. clone git repo to local folder
  command="docker exec ${g_cid} sh -c 'git clone --depth=1 --branch=master ${url} /data'"
  run "${command}" || clean_up_and_exit_fail "${command} failed!?"
  # 4. remove .git repo
  command="docker exec ${g_cid} sh -c 'rm -rf /data/.git"
  run "${command}" || clean_up_and_exit_fail "${command} failed!?"
  # 5. ensure cyber-dojo user owns everything in the volume
  command="docker exec ${g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"
  run "${command}" || clean_up_and_exit_fail "${command} failed!?"
  # 6. check the volume is a good start-point
  command="docker exec ${g_cid} sh -c './start_point_check.rb /data'"
  run_loud "${command}" || clean_up_and_exit_fail
  # clean up everything used to create the volume, but not the volume itself
  g_vol=''
  clean_up
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run() {
  local me='run'
  local command="$1"
  debug "${me}: command=${command}"
  eval ${command} > /dev/null 2>&1
  local exit_status=$?
  debug "${me}: exit_status=${exit_status}"
  if [ "${exit_status}" = 0 ]; then
    return 0
  else
    return 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_loud() {
  local me='run_loud'
  local command="$1"
  debug "${me}: command=${command}"
  eval ${command} > /dev/null
  local exit_status=$?
  debug "${me}: exit_status=${exit_status}"
  if [ "${exit_status}" = 0 ]; then
    return 0
  else
    return 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

clean_up_and_exit_fail() {
  echo $1
  clean_up
  exit_fail
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

clean_up() {
  local me='clean_up'
  # remove docker container?
  if [ "${g_cid}" != '' ]; then
    debug "${me}: doing [docker rm -f ${g_cid}]"
    docker rm -f ${g_cid} > /dev/null 2>&1
  else
    debug "${me}: g_cid='' -> NOT doing [docker rm]"
  fi
  # remove docker volume?
  if [ "${g_vol}" != '' ]; then
    debug "${me}: doing [docker volume rm ${g_vol}]"
    # previous [docker rm] command seems to sometimes complete
    # before it is safe to remove its volume?!
    sleep 1
    docker volume rm ${g_vol} > /dev/null 2>&1
  else
    debug "${me}: g_vol='' -> NOT doing [docker volume rm]"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_fail() {
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

debug() {
  # Use 'echo $1' to debug. Use ':' to not debug
  #echo $1
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_exists() {
  # don't match a substring
  local start_of_line='^'
  local start_point=$1
  local end_of_line='$'
  docker volume ls --quiet | grep -s "${start_of_line}${start_point}${end_of_line}"
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo up
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

cyber_dojo_up() {
  # cyber-dojo.rb has already been called to check arguments and handle --help
  for arg in $@
  do
    local name=$(echo ${arg} | cut -f1 -s -d=)
    local value=$(echo ${arg} | cut -f2 -s -d=)
    # --languages=start-point
    if [ "${name}" = "--languages" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_START_POINT_LANGUAGES=${value}
    fi
    # --exercises=start-point
    if [ "${name}" = "--exercises" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_START_POINT_EXERCISES=${value}
    fi
    # --custom=start-point
    if [ "${name}" = "--custom" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_START_POINT_CUSTOM=${value}
    fi
  done
  # create default start-points if necessary
  local github_cyber_dojo='https://github.com/cyber-dojo'
  if [ "${CYBER_DOJO_START_POINT_LANGUAGES}" = "${default_start_point_languages}" ]; then
    if ! start_point_exists ${default_start_point_languages}; then
      echo "Creating start-point ${default_start_point_languages} from ${github_cyber_dojo}/start-points-languages.git"
      start_point_create_git ${default_start_point_languages} "${github_cyber_dojo}/start-points-languages.git"
    fi
  fi
  if [ "${CYBER_DOJO_START_POINT_EXERCISES}" = "${default_start_point_exercises}" ]; then
    if ! start_point_exists ${default_start_point_exercises}; then
      echo "Creating start-point ${default_start_point_exercises} from ${github_cyber_dojo}/start-points-exercises.git"
      start_point_create_git ${default_start_point_exercises} "${github_cyber_dojo}/start-points-exercises.git"
    fi
  fi
  if [ "${CYBER_DOJO_START_POINT_CUSTOM}" = "${default_start_point_custom}" ]; then
    if ! start_point_exists ${default_start_point_custom}; then
      echo "Creating start-point ${default_start_point_custom}  from ${github_cyber_dojo}/start-points-custom.git"
      start_point_create_git ${default_start_point_custom} "${github_cyber_dojo}/start-points-custom.git"
    fi
  fi
  # check volumes exist
  if ! start_point_exists ${CYBER_DOJO_START_POINT_LANGUAGES}; then
    echo "FAILED: start-point ${CYBER_DOJO_START_POINT_LANGUAGES} does not exist"
    exit_fail
  fi
  if ! start_point_exists ${CYBER_DOJO_START_POINT_EXERCISES}; then
    echo "FAILED: start-point ${CYBER_DOJO_START_POINT_EXERCISES} does not exist"
    exit_fail
  fi
  if ! start_point_exists ${CYBER_DOJO_START_POINT_CUSTOM}; then
    echo "FAILED: start-point ${CYBER_DOJO_START_POINT_CUSTOM} does not exist"
    exit_fail
  fi
  echo "Using start-point --languages=${CYBER_DOJO_START_POINT_LANGUAGES}"
  echo "Using start-point --exercises=${CYBER_DOJO_START_POINT_EXERCISES}"
  echo "Using start-point --custom=${CYBER_DOJO_START_POINT_CUSTOM}"

  # bring up server with volumes
  ${docker_compose_cmd} up -d
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_volume

./cyber-dojo.rb "$@"

if [ $? != 0  ]; then
  exit_fail
fi

# cyber-dojo start-point create NAME --git=URL
if [ "$1" = 'start-point' ] && [ "$2" = 'create' ]; then
  local name=$3
  local lhs=$(echo $4 | cut -f1 -s -d=)
  local url=$(echo $4 | cut -f2 -s -d=)
  if [ "${lhs}" = '--git' ]; then
    cyber_dojo_start_point_create_git "${name}" "${url}"
  fi
fi

if [ "$1" = 'up' ]; then
  shift # up
  cyber_dojo_up "$@"
fi

if [ "$1" = 'down' ]; then
  ${docker_compose_cmd} down
fi
