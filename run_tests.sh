#!/bin/bash

./build-image.sh

for file in ./test_*.sh; do
  ${file}
done
