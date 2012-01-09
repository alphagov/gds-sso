require 'rack/accept'

module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        request = Rack::Accept::Request.new(env)
        request.best_media_type(%w{application/json text/html}) == 'application/json'
      end
    end
  end
end