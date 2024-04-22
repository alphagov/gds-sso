module GDS
  module SSO
    class PermissionDeniedError < StandardError
    end

    module ControllerMethods
      # TODO: remove this for the next major release
      class PermissionDeniedException < PermissionDeniedError
        def initialize(...)
          warn "GDS::SSO::ControllerMethods::PermissionDeniedException is deprecated, please replace with GDS::SSO::PermissionDeniedError"
          super(...)
        end
      end

      def self.included(base)
        base.rescue_from PermissionDeniedError do |e|
          if GDS::SSO::Config.api_only
            render json: { message: e.message }, status: :forbidden
          else
            render "authorisations/unauthorised", layout: "unauthorised", status: :forbidden, locals: { message: e.message }
          end
        end

        unless GDS::SSO::Config.api_only
          base.helper_method :user_signed_in?
          base.helper_method :current_user
        end
      end

      def authorise_user!(permissions)
        # Ensure that we're authenticated (and by extension that current_user is set).
        # Otherwise current_user might be nil, and we'd error out
        authenticate_user!

        GDS::SSO::AuthoriseUser.call(current_user, permissions)
      end

      def authenticate_user!
        warden.authenticate!
      end

      def user_remotely_signed_out?
        warden && warden.authenticated? && warden.user.remotely_signed_out?
      end

      def user_signed_in?
        warden && warden.authenticated? && !warden.user.remotely_signed_out?
      end

      def current_user
        warden.user if user_signed_in?
      end

      def logout
        warden.logout
      end

      def warden
        request.env["warden"]
      end
    end
  end
end
