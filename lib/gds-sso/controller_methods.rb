module GDS
  module SSO
    module ControllerMethods
      class PermissionDeniedException < StandardError
      end

      def authorise_user!(scope, permission)
        if not current_user.has_permission?(scope, permission)
          raise PermissionDeniedException
        end
      end

      def require_signin_permission!
        authorise_user!(GDS::SSO::Config.default_scope, 'signin')
      rescue PermissionDeniedException
        redirect_to cant_signin_url
      end

      def authenticate_user!
        warden.authenticate!
      end

      def user_signed_in?
        warden.authenticated?
      end

      def current_user
        warden.user if user_signed_in?
      end

      def log_out
        warden.log_out
      end

      def warden
        request.env['warden']
      end

      def self.included(base)
        base.helper_method :user_signed_in?
        base.helper_method :current_user
      end
    end
  end
end
