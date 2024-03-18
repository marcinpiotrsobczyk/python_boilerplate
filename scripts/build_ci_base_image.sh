#! /bin/bash

set -xeuo pipefail

# SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

COMMIT=${1:-"Missing commit sha"}

docker build --progress=plain --target=cxx_boilerplate_image \
  -t "cxx_boilerplate_image:$COMMIT" -f Dockerfile .

docker tag "cxx_boilerplate_image:$COMMIT" cxx_boilerplate_image
