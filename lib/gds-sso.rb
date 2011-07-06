require 'rails'

module GDS
  module SSO
    autoload :FailureApp, 'gds-sso/failure_app'

    class Engine < ::Rails::Engine
      # config.gds = # that ordered hash map config thingy

      # Initialize Warden and copy its configurations.
    #   config.app_middleware.use Warden::Manager do |config|
    #     Devise.warden_config = config
    #   end
    # 
    #   # Force routes to be loaded if we are doing any eager load.
    #   config.before_eager_load { |app| app.reload_routes! }
    # 
    #   initializer "devise.url_helpers" do
    #     Devise.include_helpers(Devise::Controllers)
    #   end
    # 
    #   initializer "devise.auth_keys" do
    #     if Devise.authentication_keys.size > 1
    #       puts "[DEVISE] You are configuring Devise to use more than one authentication key. " \
    #         "In previous versions, we automatically added #{Devise.authentication_keys[1..-1].inspect} " \
    #         "as scope to your e-mail validation, but this was changed now. If you were relying in such " \
    #         "behavior, you should remove :validatable from your models and add the validations manually. " \
    #         "To get rid of this warning, you can comment config.authentication_keys in your initializer " \
    #         "and pass the current values as key to the devise call in your model."
    #     end
    #   end
    # 
    #   initializer "devise.omniauth" do |app|
    #     Devise.omniauth_configs.each do |provider, config|
    #       app.middleware.use config.strategy_class, *config.args do |strategy|
    #         config.strategy = strategy
    #       end
    #     end
    # 
    #     if Devise.omniauth_configs.any?
    #       Devise.include_helpers(Devise::OmniAuth)
    #     end
    #   end
    # NeedOTron::Application.config.middleware.use OmniAuth::Builder do
    #   provider :gds, 'abcdefgh12345678', 'secret'
    # end
    # 
    # NeedOTron::Application.config.middleware.use Warden::Manager do |manager|
    #   manager.default_strategies :signonotron
    #   manager.failure_app = FailureApp
    # end

      config.app_middleware.use OmniAuth::Builder do
        provider :gds, 'abcdefgh12345678', 'secret'
      end

      config.app_middleware.use Warden::Manager do |manager|
        manager.default_strategies :signonotron
        manager.failure_app = GDS::SSO::FailureApp
      end
    end
  end
end

require 'gds-sso/warden_config'
require 'gds-sso/omniauth_strategy'
require 'gds-sso/user'
require 'gds-sso/controller_methods'
