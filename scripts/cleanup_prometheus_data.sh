#!/usr/bin/bash

set -xeuo pipefail

assert_is_root() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit 1
  fi
}

assert_is_root

docker exec -it -w /var/opt/gitlab/prometheus/data python_boilerplate_gitlabserver_1 ls -lath
docker exec -it -w /var/opt/gitlab/prometheus/data python_boilerplate_gitlabserver_1 rm -rf 0* wal/0* wal/checkpoint.0*
