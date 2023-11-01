#! /bin/bash

set -xeuo pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

IMAGE_TAGGED_NAME=${1:-"Missing image name"}
EXPORT_PATH=${2:-"Missing export target directory"}

echo "Attempting to export built binaries from image: ${IMAGE_TAGGED_NAME} into directory: ${EXPORT_PATH}"

export DOCKER_BUILDKIT=1

docker build -o "${EXPORT_PATH}" - << EOF
    FROM scratch
    COPY --from=${IMAGE_TAGGED_NAME} /build /
EOF
