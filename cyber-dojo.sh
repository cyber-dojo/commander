#!/bin/bash

# This file [cyber-dojo.sh] and cyber-dojo.rb, and start_point_*.rb
# combine to handle all the cyber-dojo commands except for the three
# commands that have to be handled by the cyber-dojo (no extension) script.
#
# Splitting across this file and .rb files is historical, from when
# there was no commander image and you had to install docker-compose.
# Needs consolidating into just .rb files.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$*" = 'update-images' ]; then
  echo "FAILED: unknown argument [update-images]" >&2
  exit 1
fi

./cyber-dojo.rb "$@"

if [ $? != 0 ]; then
  exit 1
fi

