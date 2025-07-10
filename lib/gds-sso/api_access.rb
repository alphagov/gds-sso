require "rack/request"

module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        return env["gds_sso.api_call"] unless env["gds_sso.api_call"].nil?
        return true if GDS::SSO::Config.api_only

        if GDS::SSO::Config.api_request_matcher
          return GDS::SSO::Config.api_request_matcher.call(Rack::Request.new(env))
        end

        !bearer_token(env).nil?
      end

      def self.bearer_token(env)
        Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |key|
          next unless env.key?(key)

          if (match = env[key].match(/\ABearer (.+)/))
            return match[1]
          end
        end

        nil
      end
    end
  end
end
