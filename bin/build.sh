#!/bin/bash -e

#generate dist directory locally.
dist_dir="./dist"
mkdir "$dist_dir"

docker compose -f docker-compose.circleci.yml build
docker compose -f docker-compose.circleci.yml run \
  circleci bash -c 'set -o pipefail;
           bash -x ./bin/generate_artifact.sh'
