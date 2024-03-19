#!/usr/bin/env bash

set -xeuo pipefail

[[ -z ${PROJECT_NAME+z} ]] && echo "env variable PROJECT_NAME not defined" && exit 127

assert_is_root() {
  if [ "$EUID" -ne 0 ]
    then echo "please run as root"
    exit 1
  fi
}

assert_is_root

docker exec -it -w /var/opt/gitlab/prometheus/data "${PROJECT_NAME}_gitlabserver_1" ls -lath
docker exec -it -w /var/opt/gitlab/prometheus/data "${PROJECT_NAME}_gitlabserver_1" rm -rf 0* wal/0* wal/checkpoint.0*
