require 'rails'

require 'gds-sso/config'
require 'gds-sso/omniauth_strategy'
require 'gds-sso/warden_config'

module GDS
  module SSO
    autoload :FailureApp,        'gds-sso/failure_app'
    autoload :ControllerMethods, 'gds-sso/controller_methods'
    autoload :User,              'gds-sso/user'

    def self.config
      yield GDS::SSO::Config
    end
    
    class Engine < ::Rails::Engine
      # Force routes to be loaded if we are doing any eager load.
      # TODO - check this one - Stolen from Devise because it looked sensible...
      config.before_eager_load { |app| app.reload_routes! }

      config.app_middleware.use ::OmniAuth::Builder do
        provider :gds, GDS::SSO::Config.oauth_id, GDS::SSO::Config.oauth_secret
      end

      config.app_middleware.use Warden::Manager do |manager|
        manager.default_strategies :gds_sso
        manager.failure_app = GDS::SSO::FailureApp
      end
    end
  end
end