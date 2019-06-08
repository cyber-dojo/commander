#!/bin/bash

image() # $1=latest $1=067eaa7
{
  echo "cyberdojo/versioner:${1}"
}

release()
{
  docker run --rm $(image latest) sh -c 'echo -n ${RELEASE}'
}

release?()
{
  [ -n "$(release)" ] && true || false
}

sha7()
{
  docker run --rm $(image latest) sh -c 'echo -n ${SHA:0:7}'
}

tag()
{
  release? && release || sha7
}

kind()
{
  release? && echo public || echo DEV-only
}

# docker tag $(image latest) $(image $(tag))
echo "Version: $(tag)"
echo "Kind: $(kind)"
exit 1
