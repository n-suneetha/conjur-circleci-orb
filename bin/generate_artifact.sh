#!/bin/bash

ORB_NAME="${1:-conjur-circleci-orb}"  # can also be set as a custom name

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

function setupCircleCI() {
    circleci setup --no-prompt \
    --host https://circleci.com \
    --token $CIRCLECI_API_KEY &>/dev/null
    [[ $? -ne 0 ]] && { echo "Failed to setup CircleCI, Please verify your API Token" ; exit 1 ; }

}

function createOrb() {
    circleci orb create "$CIRCLECI_NAMESPACE"/"$ORB_NAME" --no-prompt &>/dev/null
    [[ $? -ne 0 ]] && { echo "Failed to create the CircleCI Orb" ; exit 1 ; }
}

function orbPack() {
    [[ -z "$(find src -mindepth 1 -maxdepth 1)" ]] && { echo "The conjur-circleci-orb source code doesnot exist" ; exit 1 ; }
    circleci orb pack ./src > ./orb.yml
    [[ ! -s "./orb.yml" ]] && { echo "Failed to create the CircleCI Orb" ; exit 1 ; }
}

function orbValidate() {
    circleci orb validate ./orb.yml &>/dev/null
    [[ $? -ne 0 ]] && { echo "conjur-circleci-orb is not a valid orb" ; exit 1 ; }
    cp -f ./orb.yml ./dist &>/dev/null
    sha256sum ./dist/orb.yml > ./dist/conjur-circleci-orb_SHA256SUMS
    echo "Successfully generated the conjur-circleci-orb"
}

function main() {
    checkEnvVars "$CIRCLECI_API_KEY"
    checkEnvVars "$CIRCLECI_ORG_ID"
    checkEnvVars "$CIRCLECI_NAMESPACE"
    #Verify the namespace existence
    verifyNamespaceExistence
    #Validate and create the orb
    verifyOrbExistence
    #Pack the orb
    orbPack
    #Validate the orb
    orbValidate
}

main
