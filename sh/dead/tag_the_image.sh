#!/usr/bin/env bash
set -Eeu

tag_the_image()
{
  docker tag "$(image_name):latest" "$(image_name):$(image_tag)"
  echo "$(image_name):latest tagged to $(image_name):$(image_tag)"
}
