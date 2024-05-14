#!/usr/bin/env bash
set -euo pipefail

ORB_NAME="${1:-conjur-circleci-orb}"  # can also be set as a custom name
VERSION="$(<VERSION)"

function checkEnvVars() {
  if [[ -z "$1" ]]; then
    echo "Environment variable is not set"
    exit 1
  fi
}

function verifyNamespaceExistence() {
  circleci orb list "$CIRCLECI_NAMESPACE" &>/dev/null
  [[ $? -ne 0 ]] && { echo "No namespace was found in the CircleCI Orbs repository" ; exit 1 ; }
}

function verifyOrbExistence() {
  circleci orb list "$CIRCLECI_NAMESPACE" | grep "$ORB_NAME" &>/dev/null
  case $? in
    0) ;;
    *)
        setupCircleCI
        createOrb
    ;;
  esac
}

function orbValidate() {
  circleci orb validate ./orb.yml &>/dev/null
  [[ $? -ne 0 ]] && { echo "conjur-circleci-orb is not a valid orb" ; exit 1 ; }
}

function publishOrb() {
  circleci orb publish "${ASSET_DIRECTORY}/orb.yml" "${CIRCLECI_NAMESPACE}/${ORB_NAME}@${VERSION}"
}

function setupCircleCI() {
  circleci setup --no-prompt \
  --host https://circleci.com \
  --token $CIRCLECI_API_KEY &>/dev/null
  [[ $? -ne 0 ]] && { echo "Failed to setup CircleCI, Please verify your API Token" ; exit 1 ; }
}

function main() {
  checkEnvVars "$CIRCLECI_API_KEY"
  checkEnvVars "$CIRCLECI_ORG_ID"
  checkEnvVars "$CIRCLECI_NAMESPACE"
  checkEnvVars "$VERSION"
  checkEnvVars "$ASSET_DIRECTORY"
  #Verify the namespace existence
  verifyNamespaceExistence
  #Validate and create the orb
  verifyOrbExistence
  #Verify we have a valid orb file
  orbValidate
  #Publish the orb
  publishOrb
}