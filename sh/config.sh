#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  cd "$(root_dir)" && git rev-parse HEAD
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo cyberdojo/commander
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r sha=$(docker run --rm $(image_name):latest sh -c 'echo ${SHA}')
  echo "${sha:0:7}"
}
