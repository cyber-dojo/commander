#!/bin/bash

# This file [cyber-dojo.sh] and cyber-dojo.rb, and start_point_*.rb
# combine to handle all the cyber-dojo commands except for the three
# commands that have to be handled by the cyber-dojo (no extension) script.
#
# Splitting across this file and .rb files is historical, from when
# there was no commander image and you had to install docker-compose.
# Needs consolidating into just .rb files.

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
  local katas_data_container='cyber-dojo-katas-DATA-CONTAINER'
  docker ps --all | grep -s ${katas_data_container} > /dev/null
  if [ $? != 0 ]; then
    local context_dir=.
    cp Dockerignore.katas .dockerignore
    local tag=cyberdojo/katas
    # create a katas volume - it is mounted into the web container
    # using a volumes_from in docker-compose.yml
    docker build \
              --build-arg=CYBER_DOJO_KATAS_ROOT=/usr/src/cyber-dojo/katas \
              --tag=${tag} \
              --file=Dockerfile.katas \
              ${context_dir} > /dev/null
    rm .dockerignore
    docker create \
              --name ${katas_data_container} \
              ${tag} \
              echo 'cdfKatasDC' > /dev/null
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$*" = 'update-images' ]; then
  echo "FAILED: unknown argument [update-images]" >&2
  exit 1
fi

one_time_creation_of_katas_data_volume

./cyber-dojo.rb "$@"

if [ $? != 0 ]; then
  exit 1
fi

