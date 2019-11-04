require 'active_support/cache/null_store'

module GDS
  module SSO
    module Config
      # Name of the User class
      mattr_accessor :user_model
      @@user_model = "User"

      # OAuth ID
      mattr_accessor :oauth_id

      # OAuth Secret
      mattr_accessor :oauth_secret

      # Location of the OAuth server
      mattr_accessor :oauth_root_url
      @@oauth_root_url = "http://localhost:3001"

      mattr_accessor :auth_valid_for
      @@auth_valid_for = 20 * 3600

      mattr_accessor :cache
      @@cache = ActiveSupport::Cache::NullStore.new

      mattr_writer :api_only

      mattr_accessor :additional_mock_permissions_required

      mattr_accessor :connection_opts
      @@connection_opts = {}

      def self.permissions_for_dummy_api_user
        ["signin"].push(*additional_mock_permissions_required)
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

      def self.api_only?
        config = Rails.configuration
        default = config.respond_to?(:api_only) ? config.api_only : false
        @@api_only.nil? ? default : @@api_only
      end
    end
  end
end
