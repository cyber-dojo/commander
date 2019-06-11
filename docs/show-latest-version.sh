#!/bin/bash

versioner() # $1=latest $1=067eaa7
{
  echo "cyberdojo/versioner:${1}"
}

version()
{
  local -r release=$(docker run --rm $(versioner latest) sh -c 'echo -n ${RELEASE}')
  local -r sha7=$(docker run --rm $(versioner latest) sh -c 'echo -n ${SHA:0:7}')
  [ -n "${release}" ] && echo "${release}" || echo "${sha7}"
}

#docker tag $(versioner latest) $(versioner $(version))
echo "Version: $(version)"
