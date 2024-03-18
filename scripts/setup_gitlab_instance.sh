#!/usr/bin/bash
#
#
# WARNING with gitlab version 16.6 new registration workflow must be adopted
# see https://docs.gitlab.com/ee/architecture/blueprints/runner_tokens/

# TODO: setup token to enable job triggering via api

set -xeuo pipefail

assert_is_root() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit 1
  fi
}

assert_is_root

SCRIPTSDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "SCRIPTSDIR: ${SCRIPTSDIR}"

# shellcheck disable=SC1091
source "${SCRIPTSDIR}/common.sh"


YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_help () {

    echo -e "${YELLOW} Usage: $0 <gitlab_root> [OPTION[=VALUE]]... ${NC}"
    echo
    echo -e "${YELLOW} WARNING with gitlab version 16.6 new registration workflow must be adopted ${NC}"
    echo -e "${YELLOW} see https://docs.gitlab.com/ee/architecture/blueprints/runner_tokens/ ${NC}"
    echo "Setups gitlab instance with 2 runners"
    echo "OPTIONS:"
    echo "  --help                    Display this help screen and exit"
    echo
}

GITLAB_ROOT="${GITLAB_ROOT:-/python_boilerplate_gitlab}"
echo "GITLAB_ROOT: $GITLAB_ROOT"

while [ $# -gt 0 ]; do
  case "$1" in
    --help)
        print_help
        exit 0
        ;;
    *)
        if [ -z "$GITLAB_ROOT" ];
        then
          GITLAB_ROOT="${1}"
        else
          echo -e "${YELLOW} ERROR: '$1' is not a valid option/positional argument ${NC}"
          echo
          print_help
          exit 2
        fi
        ;;
    esac
    shift
done




function clean_up {
    docker container rm -f -v python_boilerplate_gitlabserver_1
    docker network rm python_boilerplate_gitlabnetwork || true
}
trap clean_up EXIT


rm "${GITLAB_ROOT}" -rf
clean_up

mkdir "${GITLAB_ROOT}"

mkdir "${GITLAB_ROOT}/gitlabserver" -p
mkdir "${GITLAB_ROOT}/gitlabrunner0/config" -p
mkdir "${GITLAB_ROOT}/gitlabrunner1/config" -p
mkdir "${GITLAB_ROOT}/cache" -p
mkdir "${GITLAB_ROOT}/persistent" -p
mkdir "${GITLAB_ROOT}/dind_docker_directory" -p


docker network create -d bridge --gateway 172.21.0.1 --subnet 172.21.0.0/16 python_boilerplate_gitlabnetwork

docker run --rm -dit --ip 172.21.0.2 --network python_boilerplate_gitlabnetwork \
    -v "${GITLAB_ROOT}/gitlabserver/config":/etc/gitlab \
    -v "${GITLAB_ROOT}/gitlabserver/logs":/var/log/gitlab \
    -v "${GITLAB_ROOT}/gitlabserver/data":/var/opt/gitlab \
    --name python_boilerplate_gitlabserver_1 \
    gitlab/gitlab-ce:16.7.4-ce.0


ncat --version
RETRIES=24
until ncat -z 172.21.0.2 80 || [ $RETRIES -eq 0 ]; do
    echo "waiting for gitlab ce port 80, $((RETRIES--)) remaining attempts..."
    sleep 10
done
ncat -z 172.21.0.2 80


echo "done"

# change password
password=$(obtain_initial_root_password)
echo "initial root password: ${password}"
new_password="p455w0rd"
set_new_root_password "$new_password"
echo "new root password: $new_password"

# create personal access token programmaticaly
personal_access_token=$(obtain_personal_access_token)
echo "personal access token: ${personal_access_token}"

# create runner authentication token programmaticaly
runner_authentication_token0=$(obtain_runner_authentication_token "$personal_access_token")
echo "runner authentication token 0: ${runner_authentication_token0}"

docker run --rm -it --ip 172.21.0.3 --network python_boilerplate_gitlabnetwork \
    -v "${GITLAB_ROOT}/gitlabrunner0/config":/etc/gitlab-runner gitlab/gitlab-runner:alpine3.17-v16.7.1 register \
    --non-interactive \
    --executor "docker" \
    --docker-image "ubuntu:22.04" \
    --docker-cpus 2 \
    --docker-memory 8GB \
    --docker-volumes "${GITLAB_ROOT}/cache:/cache" \
    --docker-volumes "${GITLAB_ROOT}/persistent:/persistent" \
    --docker-volumes "${GITLAB_ROOT}/dind_docker_directory:/var/lib/docker" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-network-mode "python_boilerplate_gitlabnetwork" \
    --docker-shm-size 268435456 \
    --docker-pull-policy "if-not-present" \
    --docker-memory 4g \
    --docker-privileged=true \
    --docker-tlsverify=false \
    --url "http://172.21.0.2/" \
    --description "docker-runner 0" \
    --request-concurrency 2 \
    --token "$runner_authentication_token0"


# create runner authentication token programmaticaly
runner_authentication_token1=$(obtain_runner_authentication_token "$personal_access_token")
echo "runner authentication token 0: ${runner_authentication_token1}"

docker run --rm -it --ip 172.21.0.4 --network python_boilerplate_gitlabnetwork \
    -v "${GITLAB_ROOT}/gitlabrunner1/config":/etc/gitlab-runner gitlab/gitlab-runner:alpine3.17-v16.7.1 register \
    --non-interactive \
    --executor "docker" \
    --docker-image "ubuntu:22.04" \
    --docker-cpus 2 \
    --docker-memory 8GB \
    --docker-volumes "${GITLAB_ROOT}/cache:/cache" \
    --docker-volumes "${GITLAB_ROOT}/persistent:/persistent" \
    --docker-volumes "${GITLAB_ROOT}/dind_docker_directory:/var/lib/docker" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-network-mode "python_boilerplate_gitlabnetwork" \
    --docker-shm-size 268435456 \
    --docker-pull-policy "if-not-present" \
    --docker-memory 4g \
    --docker-privileged=true \
    --docker-tlsverify=false \
    --url "http://172.21.0.2/" \
    --description "docker-runner 1" \
    --request-concurrency 2 \
    --token "$runner_authentication_token1"

sed -i 's/concurrent = 1/concurrent = 2/g' "${GITLAB_ROOT}/gitlabrunner0/config/config.toml"
sed -i 's/concurrent = 1/concurrent = 2/g' "${GITLAB_ROOT}/gitlabrunner1/config/config.toml"
