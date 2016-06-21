require 'rack/accept'

module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        request = Rack::Accept::Request.new(env)
        request.best_media_type(%w{text/html application/json}) == 'application/json'
      end
    end
  end
end
