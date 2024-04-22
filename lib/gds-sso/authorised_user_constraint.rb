module GDS
  module SSO
    class AuthorisedUserConstraint
      def initialize(permissions)
        @permissions = permissions
      end

      def matches?(request)
        warden = request.env["warden"]
        warden.authenticate! if !warden.authenticated? || warden.user.remotely_signed_out?

        AuthoriseUser.call(warden.user, permissions)
        true
      end

    private

      attr_reader :permissions
    end
  end
end
