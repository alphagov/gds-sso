#!/bin/bash -xe

# Make sure this runs, even if something blows up.
trap "bundle exec rake signonotron:stop" EXIT

# Gemfile.lock is not in source control because this is a gem
rm -f Gemfile.lock
bundle install --path "${HOME}/bundles/${JOB_NAME}"

bundle exec rake test

bundle exec rake signonotron:start
bundle exec rake spec

bundle exec rake publish_gem
