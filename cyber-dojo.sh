#!/bin/bash

# This file [cyber-dojo.sh] and cyber-dojo.rb, and start_point_*.rb
# combine to handle all the cyber-dojo commands except for the three
# commands that have to be handled by the cyber-dojo (no extension) script.
#
# Splitting across this file and .rb files is messy and historical,
# from when there was no commander image and you had to
# install docker-compose.
# Needs consolidating into just .rb files.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$1" == '--debug' ]; then
  debug_on='true'
  shift
else
  debug_on='false'
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

debug()
{
  if [ "${debug_on}" == 'true' ]; then
    echo $*
  else
    :
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"

cyber_dojo_hub=cyberdojo
cyber_dojo_commander=${cyber_dojo_hub}/commander

default_start_point_languages=languages
default_start_point_exercises=exercises
default_start_point_custom=custom
default_nginx_port=80

# set environment variables required by docker-compose.yml
export CYBER_DOJO_START_POINT_LANGUAGES=${default_start_point_languages}
export CYBER_DOJO_START_POINT_EXERCISES=${default_start_point_exercises}
export CYBER_DOJO_START_POINT_CUSTOM=${default_start_point_custom}
export CYBER_DOJO_NGINX_PORT=${default_nginx_port}
export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_volume()
{
  # The katas data-volume is not created as a named volume because
  # it predates that feature.
  # A previous version of this script detected if /var/www/cyber-dojo/katas
  # existed on the host in which case it assumed an old cyber-dojo server
  # was being upgraded and automatically copied it into the new volume.
  # It doesn't do that any more. If you want to upgrade an older server
  # have a look at old-notes/copy_katas_into_data_container.sh in
  # https://github.com/cyber-dojo/cyber-dojo
  docker ps --all | grep -s ${CYBER_DOJO_KATAS_DATA_CONTAINER} > /dev/null
  if [ $? != 0 ]; then
    CONTEXT_DIR=.
    cp Dockerignore.katas .dockerignore
    local tag=${cyber_dojo_hub}/katas
    # create a katas volume - it is mounted into the web container
    # using a volumes_from in docker-compose.yml
    docker build \
              --build-arg=CYBER_DOJO_KATAS_ROOT=/usr/src/cyber-dojo/katas \
              --tag=${tag} \
              --file=Dockerfile.katas \
              ${CONTEXT_DIR} > /dev/null
    rm .dockerignore
    docker create \
              --name ${CYBER_DOJO_KATAS_DATA_CONTAINER} \
              ${tag} \
              echo 'cdfKatasDC' > /dev/null
  fi
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo start-point create --git=URL
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

g_cid=''      # if this is not '' then clean_up [docker rm]'s the container
g_vol=''      # if this is not '' then clean_up [docker volume rm]'s the volume

start_point_git_sparse_pull()
{
  local url=$1
  declare -a commands=(
    "cd /data && git init"
    "cd /data && git remote add origin ${url}"
    "cd /data && git config core.sparseCheckout true"
    "cd /data && echo !**/_docker_context >> .git/info/sparse-checkout"
    "cd /data && echo /\*                 >> .git/info/sparse-checkout"
    "cd /data && git pull --depth=1 origin master"
    "cd /data && rm -rf .git"
  )
  for cmd in "${commands[@]}"
  do
    command="docker exec ${g_cid} sh -c '${cmd}'"
    run_quiet "${command}" || clean_up_and_exit_fail "${command} failed!?"
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_create_git()
{
  local name=$1
  local url=$2
  if start_point_exists ${name}; then
    echo "FAILED: a start-point called ${name} already exists"
    exit_fail
  fi

  # 1. make an empty docker volume
  command="docker volume create --name=${name} --label=cyber-dojo-start-point=${url}"
  run_quiet "${command}" || clean_up_and_exit_fail "${command} FAILED"
  g_vol=${name}

  # 2. mount empty docker volume inside docker container
  command="docker create
               --interactive
               --user=root
               --volume=${name}:/data
               ${cyber_dojo_commander} sh"
  g_cid=`${command}`
  command="docker start ${g_cid}"
  run_quiet "${command}" || clean_up_and_exit_fail "${command} failed!?"

  # 3. pull git repo into docker volume
  start_point_git_sparse_pull ${url}

  # 4. ensure cyber-dojo user owns everything in the volume
  command="docker exec ${g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"
  run_quiet "${command}" || clean_up_and_exit_fail "${command} failed!?"

  # 5. check the volume is a good start-point
  command="docker exec ${g_cid} sh -c './start_point_check.rb /data'"
  run_loud "${command}" || clean_up_and_exit_fail

  # 6. clean up everything used to create the volume, but not the volume itself
  g_vol=''
  clean_up
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_quiet()
{
  local me='run_quiet'
  local command="$1"
  debug "${me}: command=${command}"
  eval ${command} > /dev/null 2>&1
  local exit_status=$?
  debug "${me}: exit_status=${exit_status}"
  return ${exit_status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run_loud()
{
  local me='run_loud'
  local command="$1"
  debug "${me}: command=${command}"
  eval ${command} > /dev/null
  local exit_status=$?
  debug "${me}: exit_status=${exit_status}"
  return ${exit_status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

clean_up_and_exit_fail()
{
  echo $*
  clean_up
  exit_fail
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

clean_up()
{
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_fail()
{
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_exists()
{
  # don't match a substring
  local start_of_line='^'
  local start_point=$1
  local end_of_line='$'
  docker volume ls --quiet | grep -s "${start_of_line}${start_point}${end_of_line}" > /dev/null
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo up
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

cyber_dojo_up()
{
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
    # --port=listen-port
    if [ "${name}" = "--port" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_NGINX_PORT=${value}
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
      echo "Creating start-point ${default_start_point_custom} from ${github_cyber_dojo}/start-points-custom.git"
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
  echo "Using --languages=${CYBER_DOJO_START_POINT_LANGUAGES}"
  echo "Using --exercises=${CYBER_DOJO_START_POINT_EXERCISES}"
  echo "Using --custom=${CYBER_DOJO_START_POINT_CUSTOM}"
  echo "Using --port=${CYBER_DOJO_NGINX_PORT}"

  # Bring up server with volumes
  # It seems a successful [docker-compose up] writes to stderr !?
  # See https://github.com/docker/compose/issues/3267
  ${docker_compose_cmd} up -d 2>&1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$*" = 'update-images' ]; then
  echo "FAILED: unknown argument [update-images]" >&2
  exit_fail
fi

one_time_creation_of_katas_data_volume

if [ "${debug_on}" == 'true' ]; then
  ./cyber-dojo.rb "--debug" "$@"
else
  ./cyber-dojo.rb "$@"
fi

if [ $? != 0 ]; then
  exit_fail
fi

if [ "$1" = 'up' ] && [ "$2" != '--help' ]; then
  shift # up
  cyber_dojo_up "$@"
fi
