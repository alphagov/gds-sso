module GDS
  module SSO
    module ControllerMethods
      class PermissionDeniedException < StandardError
      end

      def self.included(base)
        base.rescue_from PermissionDeniedException do |e|
          render "authorisations/unauthorised", layout: "unauthorised", status: :forbidden, locals: { message: e.message }
        end
        base.helper_method :user_signed_in?
        base.helper_method :current_user
      end


      def authorise_user!(scope, permission)
        if not current_user.has_permission?(scope, permission)
          raise PermissionDeniedException, "Sorry, you don't seem to have the #{permission} permission for #{scope}."
        end
      end

      def require_signin_permission!
        authorise_user!(GDS::SSO::Config.default_scope, 'signin')
      rescue PermissionDeniedException
        headers["X-Slimmer-Skip"] = "1" # If slimmer used, without this you would see a generic 400 error page
        render "authorisations/cant_signin", layout: "unauthorised", status: :forbidden
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
    end
  end
end
