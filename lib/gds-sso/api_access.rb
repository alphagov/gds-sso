module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        /\ABearer / === env['HTTP_AUTHORIZATION'].to_s
      end
    end
  end
end
