For super-quickness:

You need to tell us the name of your User model, which needs to respond to klass.find_by_uid(uid), and must include the GDS::SSO::User module.

Create a `config/initializers/gds-sso.rb` that looks like:

    GDS::SSO.config do |config|
      config.user_model = 'User'
    end
    
    