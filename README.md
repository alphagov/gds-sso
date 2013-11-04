## Introduction

GDS-SSO provides everything needed to integrate an application with the signonotron2 single-sign-on
(https://github.com/alphagov/signonotron2) as used by the Government Digital Service, though it
will probably also work with a range of other oauth2 providers.

It is a wrapper around omniauth that adds a 'strategy' for oAuth2 integration against signonotron2,
and the necessary controller to support that request flow.

For more details on OmniAuth and oAuth2 integration see https://github.com/intridea/omniauth


## Integration with a Rails 3+ app

To use gds-sso you will need an oauth client ID and secret for signonotron2 or a compatible system.
These can be provided by one of the team with admin access to signonotron2.

Then include the gem in your Gemfile:

    gem 'gds-sso', :git => 'https://github.com/alphagov/gds-sso.git'

Create a `config/initializers/gds-sso.rb` that looks like:

    GDS::SSO.config do |config|
      config.user_model   = 'User'

      # set up ID and Secret in a way which doesn't require it to be checked in to source control...
      config.oauth_id     = ENV['OAUTH_ID']
      config.oauth_secret = ENV['OAUTH_SECRET']

      # optional config for location of signonotron2
      config.oauth_root_url = "http://localhost:3001"
    end

The user model must include the GDS::SSO::User module.

It should have the following fields:

    string   "name"
    string   "email"
    string   "uid"
    string   "organisation"
    array    "permissions"
    boolean  "remotely_signed_out", :default => false

You also need to include `GDS::SSO::ControllerMethods` in your ApplicationController

For ActiveRecord, you probably want to declare permissions as "serialized" like this:

    serialize :permissions, Array


## Use in development mode

In development, you generally want to be able to run an application without needing to run your own SSO server to be running as well. GDS-SSO facilitates this by using a 'mock' mode in development. Mock mode loads an arbitrary user from the local application's user tables:

    GDS::SSO.test_user || GDS::SSO::Config.user_klass.first

To make it use a real strategy (e.g. if you're testing an app against the signon server), you will need to ensure that your signonotron2 database has got OAuth config that matches what the apps use in development mode. To do this, run this in signonotron2:

    bundle exec ./script/make_oauth_work_in_dev

Once that's done, set an environment variable when you run your app. e.g.:

    GDS_SSO_STRATEGY=real bundle exec rails s 

