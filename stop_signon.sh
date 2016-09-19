#! /bin/bash

set -ex

GEM_ROOT=$(cd $(dirname $0) ; pwd)
TMP_ROOT=${GEM_ROOT}/tmp
APP_ROOT=${TMP_ROOT}/signonotron2
PID_FILE=${APP_ROOT}/server.pid

if [[ -f ${PID_FILE} && -n $(cat ${PID_FILE}) ]]
then
  kill $(cat ${PID_FILE}) 2>&1 >/dev/null || true
fi
