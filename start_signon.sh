#! /bin/bash

set -ex

GEM_ROOT=$(cd $(dirname $0) ; pwd)
TMP_ROOT=${GEM_ROOT}/tmp
APP_ROOT=${TMP_ROOT}/signon
PID_FILE=${APP_ROOT}/server.pid

echo ${APP_ROOT}

mkdir -p ${TMP_ROOT}
if [[ -d ${APP_ROOT} ]]
then
  cd ${APP_ROOT}
  git clean -fdx
  git fetch origin
  git reset --hard origin/master
else
  git clone https://github.com/alphagov/signon ${APP_ROOT}
  cd ${APP_ROOT}
fi

if [[ -n ${SIGNON_COMMITISH} ]]
then
  git checkout ${SIGNON_COMMITISH}
fi

bundle install --path ${APP_ROOT}_bundle

${GEM_ROOT}/stop_signon.sh

DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=test bundle exec rake db:reset
RAILS_ENV=test bundle exec rails s -p 4567 -d -P ${PID_FILE}
