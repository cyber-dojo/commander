#!/bin/bash

# Intended to go inside cmd/sh/start-point-create.sh

detagged_url()
{
  # https://github.com/a/b/name.git?tag3.7.4 ==> "https://github.com/a/b/name.git"
  # https://github.com/a/b/name.git          ==> "https://github.com/a/b/name.git"
  echo ${1%\?*}
}

url_tag()
{
  # https://github.com/a/b/name.git?tag3.7.4 ==> "3.7.4"
  # https://github.com/a/b/name.git          ==> "master"
  local -r detagged=$(detagged_url $1)
  local -r offset=${#detagged}+1
  local -r params=${1:${offset}:9999}
  local -r tag=${params##*tag=}
  echo ${tag:-master}
}

url="https://github.com/cyber-dojo-languages/python-unittest.git?tag=3.7.4"
echo
echo '----------------------------------'
echo ".....url:${url}:"
echo "detagged:$(detagged_url $url):"
echo "...value:$(url_tag $url):"

url="https://github.com/cyber-dojo-languages/python-unittest.git"
echo
echo '----------------------------------'
echo ".....url:${url}:"
echo "detagged:$(detagged_url $url):"
echo "...value:$(url_tag $url):"
