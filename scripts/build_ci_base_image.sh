#! /bin/bash

set -xeuo pipefail


COMMIT=${1:-"Missing commit sha"}

docker build --progress=plain --target=python_boilerplate_image \
  -t "python_boilerplate_image:$COMMIT" -f Dockerfile .

docker tag "python_boilerplate_image:$COMMIT" python_boilerplate_image
