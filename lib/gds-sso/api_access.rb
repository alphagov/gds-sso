module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        env['HTTP_ACCEPT'] == 'application/json'
      end

      def self.valid_api_call?(env)
        api_call?(env) && /\ABearer / === env['HTTP_AUTHORIZATION'].to_s
      end
    end
  end
end
