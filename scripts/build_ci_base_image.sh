#!/usr/bin/env bash

set -xeuo pipefail
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SCRIPTSDIR="${SCRIPTPATH}"
SRCDIR="${SCRIPTSDIR}/.."

[[ -z ${PROJECT_NAME+z} ]] && echo "env variable PROJECT_NAME not defined" && exit 127
[[ -z ${COMMIT+z} ]] && echo "env variable COMMIT not defined" && exit 127
[[ -z ${LATEST_IMAGE_NAME+z} ]] && echo "env variable LATEST_IMAGE_NAME not defined" && exit 127


docker build --progress=plain --target=image \
  -t "${PROJECT_NAME}_image:${COMMIT}" -f Dockerfile "$SRCDIR"

docker tag "${PROJECT_NAME}_image:${COMMIT}" "${LATEST_IMAGE_NAME}"
