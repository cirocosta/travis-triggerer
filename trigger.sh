#!/bin/bash

set -o errexit

readonly TRAVIS_API_ADDRESS="${TRAVIS_API_ADDRESS:-https://api.travis-ci.com}"

main() {
  local repo=$1

  ensure_environment_variables_set
  ensure_repo_set $repo
  trigger_build $repo
}

ensure_environment_variables_set() {
  if [[ -z "$TRAVIS_ACCESS_TOKEN" ]]; then
    echo "Error:
    An access token must be provided in the environment
    variable TRAVIS_ACCESS_TOKEN.
    
    To get one, use the command like:
    
      travis login --pro
      travis token --pro
    
    Then set the environment variable TRAVIS_ACCESS_TOKEN to
    the token received.
    
    Aborting.
    "
    exit 1
  fi

  if [[ -z "$TRAVIS_REPO_SLUG" || -z "$TRAVIS_BUILD_ID" ]]; then
    echo "Error:
    Required environment variables TRAVIS_REPO_SLUG and/or TRAVIS_BUILD_ID
    not set.
    
    This might be due to not issuing the command from a Travis build.

    If you wish to continue the execution anyway, make sure you have
    both environment variables set.
    
    Aborting.
    "
    exit 1
  fi

}

ensure_repo_set() {
  if [[ -z "$repo" ]]; then
    echo "Error:
    A repository was expected to be supplied as the
    argument but an empty string was received.
    
    Usage:
      ./travis-trigger.sh <repo>
      
    Example:
      ./travis-trigger.sh wedeploy/images
      
    Aborting.
    "
    exit 1
  fi
}

trigger_build() {
  local repo=$1
  local travis_repo=${repo/\//%2F}
  local body="{
  \"request\": {
    \"message\": \"(AUTO) Triggered by Travis [repo=$TRAVIS_REPO_SLUG],build=$TRAVIS_BUILD_ID]\",
    \"branch\": \"master\"
  }
}"

  echo "INFO:
  Triggering build for repository [$repo].
  
  TRAVIS_BUILD_ID:    $TRAVIS_BUILD_ID
  TRAVIS_REPO_SLUG:   $TRAVIS_REPO_SLUG
  TRAVIS_API_ADDRESS: $TRAVIS_API_ADDRESS
  "

  local request_status_code=$(
    curl \
      --silent \
      --output /dev/stderr \
      --write-out "%{http_code}" \
      --header "Content-Type: application/json" \
      --header "Accept: application/json" \
      --header "Travis-API-Version: 3" \
      --header "Authorization: token $TRAVIS_ACCESS_TOKEN" \
      --data "$body" \
      "${TRAVIS_API_ADDRESS}/repo/$travis_repo/requests"
  )

  if [[ "$request_status_code" == "200" ]]; then
    echo "
    Success! Build for repository $repo triggered.
    "
  else
    echo "Error:
    Something went wrong with the triggering of a build for repository [$repo].
    
    Make sure you have set a TRAVIS_ACCESST_TOKEN that is able to trigger 
    build for the desired repository.

    Aborting.
    "

    exit 1
  fi
}

main "$@"
