#!/bin/bash -xe

# Capture the clean path so that we can use it to execute signon isolated from gds-sso
export ORIGINAL_PATH=$PATH

# Make sure this runs, even if something blows up.
trap "kill $(lsof -Fp -i :4567 | sed 's/^p//') || true" EXIT

# Gemfile.lock is not in source control because this is a gem
rm -f Gemfile.lock
rm -f gemfiles/*.gemfile.lock

# Exclude /tmp from git clean as it only contains the signonotron checkout
git clean -fdxe /tmp

for ruby_version in 1.9.3 2.1 2.2; do
  for gemfile in rails_3.2 rails_4.0 rails_4.1; do
    RBENV_VERSION=${ruby_version} bundle install \
      --path "${HOME}/bundles/${JOB_NAME}" \
      --gemfile "gemfiles/${gemfile}.gemfile"

    RBENV_VERSION=${ruby_version} \
      BUNDLE_PATH="${HOME}/bundles/${JOB_NAME}" \
      BUNDLE_GEMFILE="gemfiles/${gemfile}.gemfile" \
      bundle exec rake
  done
done

if [[ -n "$PUBLISH_GEM" ]]; then
  bundle install
  bundle exec rake publish_gem
fi
