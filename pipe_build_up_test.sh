#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

cd ${my_dir}
./build.sh
docker run --rm cyberdojo/commander sh -c 'cd test/rb && ./run.sh'

./test/sh/run.sh
