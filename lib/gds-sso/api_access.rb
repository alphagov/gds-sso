require 'rack/accept'

module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        request = Rack::Accept::Request.new(env)
        request.best_media_type(%w{text/html application/json}) == 'application/json'
      end

      def self.has_bearer_token?(env)
        env['Authorization'] && env['Authorization'].match(/^Bearer /)
      end

      def self.oauth_api_call?(env)
        has_bearer_token?(env)
      end
    end
  end
end