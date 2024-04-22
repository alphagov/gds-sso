require "active_support/cache/null_store"
require "plek"

module GDS
  module SSO
    module Config
      # rubocop:disable Style/ClassVars

      # Name of the User class
      mattr_accessor :user_model
      @@user_model = "User"

      # OAuth ID
      mattr_accessor :oauth_id
      @@oauth_id = ENV.fetch("GDS_SSO_OAUTH_ID", "test-oauth-id")

      # OAuth Secret
      mattr_accessor :oauth_secret
      @@oauth_secret = ENV.fetch("GDS_SSO_OAUTH_SECRET", "test-oauth-secret")

      # Location of the OAuth server
      mattr_accessor :oauth_root_url
      @@oauth_root_url = Plek.new.external_url_for("signon")

      mattr_accessor :auth_valid_for
      @@auth_valid_for = 20 * 3600

      mattr_accessor :cache

      mattr_accessor :api_only

      mattr_accessor :intercept_401_responses
      @@intercept_401_responses = true

      mattr_accessor :additional_mock_permissions_required

      mattr_accessor :connection_opts
      @@connection_opts = {
        request: {
          open_timeout: 5,
        },
      }

      def self.permissions_for_dummy_api_user
        %w[signin].push(*additional_mock_permissions_required)
      end

      def self.user_klass
        user_model.to_s.constantize
      end

      def self.use_mock_strategies?
        default_strategy = if %w[development test].include?(Rails.env)
                             "mock"
                           else
                             "real"
                           end

        ENV.fetch("GDS_SSO_STRATEGY", default_strategy) == "mock"
      end

      # rubocop:enable Style/ClassVars
    end
  end
end
