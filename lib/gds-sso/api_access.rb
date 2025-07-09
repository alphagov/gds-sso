require "rack/request"

module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        if GDS::SSO::Config.api_request_matcher
          return GDS::SSO::Config.api_request_matcher.call(Rack::Request.new(env))
        end

        bearer_token_present?(env)
      end

      def self.bearer_token_present?(env)
        env["HTTP_AUTHORIZATION"].to_s.match?(/\ABearer /)
      end
    end
  end
end
