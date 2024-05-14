#!/usr/bin/env bash
set -euo pipefail

#generate dist directory locally.
dist_dir="./dist"
mkdir "$dist_dir"

if [ $# -ne 2 ]; then
  echo "Incorrect number of parameters."
  echo "Usage: promote.sh <asset directory> <version>"
  exit 1
fi

export VERSION=$2
export ASSET_DIRECTORY=$1

docker compose -f docker-compose.circleci.yml build
docker compose -f docker-compose.circleci.yml run \
  circleci bash -c 'set -o pipefail;
           bash -x ./bin/publish_artifact.sh'
