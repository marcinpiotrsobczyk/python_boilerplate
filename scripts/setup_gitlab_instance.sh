#!/usr/bin/env bash
#
#
# WARNING with gitlab version 16.6 new registration workflow must be adopted
# see https://docs.gitlab.com/ee/architecture/blueprints/runner_tokens/

# TODO: setup token to enable job triggering via api

set -xeuo pipefail
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SCRIPTSDIR="${SCRIPTPATH}"
SRCDIR="${SCRIPTSDIR}/.."


[[ -z ${PROJECT_NAME+z} ]] && echo "env variable PROJECT_NAME not defined" && exit 127
[[ -z ${GITLAB_ROOT+z} ]] && echo "env variable GITLAB_ROOT not defined" && exit 127
[[ -z ${NETWORK_16BIT_PREFIX+z} ]] && echo "env variable NETWORK_16BIT_PREFIX not defined" && exit 127
[[ -z ${GITLAB_SERVER_IMAGE+z} ]] && echo "env variable GITLAB_SERVER_IMAGE not defined" && exit 127
[[ -z ${GITLAB_RUNNER_IMAGE+z} ]] && echo "env variable GITLAB_RUNNER_IMAGE not defined" && exit 127
[[ -z ${LATEST_IMAGE_NAME+z} ]] && echo "env variable LATEST_IMAGE_NAME not defined" && exit 127

assert_is_root() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit 1
  fi
}
assert_is_root


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


while [ $# -gt 0 ]; do
  case "$1" in
    --help)
        print_help
        exit 0
        ;;
    *)
        echo -e "${YELLOW} ERROR: '$1' is not a valid option/positional argument ${NC}"
        echo
        print_help
        exit 2
        ;;
    esac
    shift
done




function clean_up {
    echo "PERFORMING CLEANUP"
    docker container rm -f -v "${PROJECT_NAME}_gitlabserver_1"
    docker network rm "${PROJECT_NAME}_gitlabnetwork" || true
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


docker network create -d bridge \
    --gateway "${NETWORK_16BIT_PREFIX}.0.1" \
    --subnet "${NETWORK_16BIT_PREFIX}.0.0/16" \
    "${PROJECT_NAME}_gitlabnetwork"

docker run --rm -dit \
    --ip "${NETWORK_16BIT_PREFIX}.0.2" \
    --network "${PROJECT_NAME}_gitlabnetwork" \
    --volume "${GITLAB_ROOT}/gitlabserver/config":/etc/gitlab \
    --volume "${GITLAB_ROOT}/gitlabserver/logs":/var/log/gitlab \
    --volume "${GITLAB_ROOT}/gitlabserver/data":/var/opt/gitlab \
    --name "${PROJECT_NAME}_gitlabserver_1" \
    "${GITLAB_SERVER_IMAGE}"


ncat --version
RETRIES=24
until ncat -z "${NETWORK_16BIT_PREFIX}.0.2" 80 || [ $RETRIES -eq 0 ]; do
    echo "waiting for gitlab ce port 80, $((RETRIES--)) remaining attempts..."
    sleep 10
done
ncat -z "${NETWORK_16BIT_PREFIX}.0.2" 80


echo "done"

# change password
password=$(obtain_initial_root_password)
echo "initial root password: ${password}"
new_password="p455w0rd"
set_new_root_password "$new_password"
echo "new root password: $new_password"

# create personal access token programmatically
personal_access_token=$(obtain_personal_access_token)
echo "personal access token: ${personal_access_token}"

# create runner authentication token programmatically
runner_authentication_token0=$(obtain_runner_authentication_token "$personal_access_token")
echo "runner authentication token 0: ${runner_authentication_token0}"

docker run --rm -it --ip 172.21.0.3 --network "${PROJECT_NAME}_gitlabnetwork" \
    -v "${GITLAB_ROOT}/gitlabrunner0/config":/etc/gitlab-runner "${GITLAB_RUNNER_IMAGE}" register \
    --non-interactive \
    --executor "docker" \
    --docker-image "${LATEST_IMAGE_NAME}" \
    --docker-cpus 2 \
    --docker-memory 8GB \
    --docker-volumes "${GITLAB_ROOT}/cache:/cache" \
    --docker-volumes "${GITLAB_ROOT}/persistent:/persistent" \
    --docker-volumes "${GITLAB_ROOT}/dind_docker_directory:/var/lib/docker" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-network-mode "${PROJECT_NAME}_gitlabnetwork" \
    --docker-shm-size 268435456 \
    --docker-pull-policy "if-not-present" \
    --docker-memory 4g \
    --docker-privileged=true \
    --docker-tlsverify=false \
    --url "http://${NETWORK_16BIT_PREFIX}.0.2/" \
    --description "docker-runner 0" \
    --request-concurrency 2 \
    --token "$runner_authentication_token0"


# create runner authentication token programmatically
runner_authentication_token1=$(obtain_runner_authentication_token "$personal_access_token")
echo "runner authentication token 0: ${runner_authentication_token1}"

docker run --rm -it --ip 172.21.0.4 --network "${PROJECT_NAME}_gitlabnetwork" \
    -v "${GITLAB_ROOT}/gitlabrunner1/config":/etc/gitlab-runner "${GITLAB_RUNNER_IMAGE}" register \
    --non-interactive \
    --executor "docker" \
    --docker-image "${LATEST_IMAGE_NAME}" \
    --docker-cpus 2 \
    --docker-memory 8GB \
    --docker-volumes "${GITLAB_ROOT}/cache:/cache" \
    --docker-volumes "${GITLAB_ROOT}/persistent:/persistent" \
    --docker-volumes "${GITLAB_ROOT}/dind_docker_directory:/var/lib/docker" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
    --docker-network-mode "${PROJECT_NAME}_gitlabnetwork" \
    --docker-shm-size 268435456 \
    --docker-pull-policy "if-not-present" \
    --docker-memory 4g \
    --docker-privileged=true \
    --docker-tlsverify=false \
    --url "http://${NETWORK_16BIT_PREFIX}.0.2/" \
    --description "docker-runner 1" \
    --request-concurrency 2 \
    --token "$runner_authentication_token1"

sed -i 's/concurrent = 1/concurrent = 2/g' "${GITLAB_ROOT}/gitlabrunner0/config/config.toml"
sed -i 's/concurrent = 1/concurrent = 2/g' "${GITLAB_ROOT}/gitlabrunner1/config/config.toml"
