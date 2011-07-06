For super-quickness:

You need to tell us the name of your User model, which needs to respond to klass.find_by_uid(uid), and must include the GDS::SSO::User module.

You also need to include `GDS::SSO::ControllerMethods` in your ApplicationController

Create a `config/initializers/gds-sso.rb` that looks like:

    GDS::SSO.config do |config|
      config.user_model   = 'User'
      # set up ID and Secret in a way which doesn't require it to be checked in to source control...
      config.oauth_id     = ENV['OAUTH_ID']
      config.oauth_secret = ENV['OAUTH_SECRET']
      # optional config for location of sign-on-o-tron
      config.oauth_root_url = "http://localhost:3001"
    end
