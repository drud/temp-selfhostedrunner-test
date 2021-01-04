#!/bin/bash
# This script is used to build drud/ddev using buildkite

echo "github actions building at $(date) on $(hostname) for OS=$(go env GOOS) in $PWD with golang=$(go version) docker=$(docker version --format '{{.Server.Version}}') and docker-compose $(docker-compose version --short) ddev version=$(ddev --version)"

export GOTEST_SHORT=1
export DRUD_NONINTERACTIVE=true

set -o errexit
set -o pipefail
set -o nounset
set -x

# On macOS, restart docker to avoid bugs where containers can't be deleted
if [ "${OSTYPE%%[0-9]*}" = "darwin" ]; then
  killall Docker || true
  nohup /Applications/Docker.app/Contents/MacOS/Docker --unattended &
  sleep 10
fi

# Make sure docker is working
echo "Waiting for docker to come up: $(date)"
date && timeout -v 10m bash -c 'while ! docker ps >/dev/null 2>&1 ; do
  sleep 10
  echo "Waiting for docker to come up: $(date)"
done'
echo "Testing again to make sure docker came up: $(date)"
if ! docker ps >/dev/null 2>&1 ; then
  echo "Docker is not running, exiting"
  exit 1
fi

docker run drud/ddev-webserver:v1.16.3 bash -c "echo docker seems to be working"
