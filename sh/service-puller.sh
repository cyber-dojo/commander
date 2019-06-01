#!/bin/bash
set -e

declare -a start_point_names=(
  custom exercises languages
)

declare -a service_names=(
  differ mapper nginx ragger runner saver web zipper
  grafana prometheus
)

for name in "${start_point_names[@]}"; do
  docker pull cyberdojo/${name}:latest
done

for name in "${service_names[@]}"; do
  docker pull cyberdojo/${name}:latest
done
