#!/bin/bash
set -e

VENV_PATH="${HOME}/venv/${JOB_NAME}"

[ -x ${VENV_PATH}/bin/pip ] || virtualenv ${VENV_PATH}
. ${VENV_PATH}/bin/activate

pip install -q ghtools

REPO="alphagov/signonotron2"
GITHUB_STATUS_CONTEXT="Test signon changes against gds-sso master"
gh-status "$REPO" "$SIGNON_COMMITISH" pending -d "\"Testing gds-sso against changes #${BUILD_NUMBER} on Jenkins\"" -u "$BUILD_URL" -c "$GITHUB_STATUS_CONTEXT" >/dev/null

if ./jenkins.sh; then
  gh-status "$REPO" "$SIGNON_COMMITISH" success -d "\"Testing gds-sso against changes #${BUILD_NUMBER} succeeded on Jenkins\"" -u "$BUILD_URL" -c "$GITHUB_STATUS_CONTEXT" >/dev/null
  exit 0
else
  gh-status "$REPO" "$SIGNON_COMMITISH" failure -d "\"Testing gds-sso against changes #${BUILD_NUMBER} failed on Jenkins\"" -u "$BUILD_URL" -c "$GITHUB_STATUS_CONTEXT" >/dev/null
  exit 1
fi
