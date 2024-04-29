module GDS
  module SSO
    class Railtie < Rails::Railtie
      config.action_dispatch.rescue_responses.merge!(
        "GDS::SSO::PermissionDeniedError" => :forbidden,
      )

      initializer "gds-sso.initializer" do
        GDS::SSO.config do |config|
          config.cache = Rails.cache
          config.api_only = Rails.configuration.api_only
        end
        OmniAuth.config.logger = Rails.logger
      end
    end
  end
end
