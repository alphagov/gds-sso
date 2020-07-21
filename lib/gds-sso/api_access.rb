module GDS
  module SSO
    class ApiAccess
      def self.api_call?(env)
        env["HTTP_AUTHORIZATION"].to_s =~ /\ABearer /
      end
    end
  end
end
