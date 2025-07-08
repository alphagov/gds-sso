module GDS
  module SSO
    class AuthorisedUserConstraint
      def initialize(permissions)
        @permissions = permissions
      end

      def matches?(request)
        user = GDS::SSO.authenticate_user!(request.env["warden"])

        GDS::SSO::AuthoriseUser.call(user, permissions)
        true
      end

    private

      attr_reader :permissions
    end
  end
end
