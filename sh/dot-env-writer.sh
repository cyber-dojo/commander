#!/bin/bash

env_var_for()
{
  name="${1}"
  container="cyber-dojo-${name}"
  image_name=`docker inspect --format='{{.Config.Image}}' ${container} | xargs`
  sha=`docker exec -i ${container} sh -c  'echo -n ${SHA}' | xargs`
  NAME=$(echo "${name}" | tr a-z A-Z)
  echo "CYBER_DOJO_${NAME}=${image_name}:${sha:0:7}"
}

declare -a names=(
  "custom" "exercises" "languages"
  "differ" "mapper" "nginx" "ragger" "runner" "saver" "web" "zipper"
  "grafana" "prometheus"
)
for name in "${names[@]}"
do
  echo "$(env_var_for ${name})"
done
