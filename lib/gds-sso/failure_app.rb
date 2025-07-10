require "action_controller/metal"
require "rails"

# Failure application that will be called every time :warden is thrown from
# any strategy or hook.
module GDS
  module SSO
    class FailureApp < ActionController::Metal
      include ActionController::Redirecting
      include AbstractController::Rendering
      include ActionController::Rendering
      include ActionController::Renderers
      use_renderers :json

      def self.call(env)
        if GDS::SSO::ApiAccess.api_call?(env)
          action(:api_invalid_token).call(env)
        elsif GDS::SSO::Config.api_only
          action(:api_missing_token).call(env)
        else
          action(:redirect).call(env)
        end
      end

      def redirect
        store_location!
        redirect_to "/auth/gds"
      end

      def api_invalid_token
        api_unauthorized("Bearer token does not appear to be valid", "invalid_token")
      end

      def api_missing_token
        api_unauthorized("No bearer token was provided", "invalid_request")
      end

      # Stores requested uri to redirect the user after signing in. We cannot use
      # scoped session provided by warden here, since the user is not authenticated
      # yet, but we still need to store the uri based on scope, so different scopes
      # would never use the same uri to redirect.

      # TOTALLY NOT DOING THE SCOPE THING. PROBABLY SHOULD.
      def store_location!
        session["return_to"] = request.env["warden.options"][:attempted_path] if request.get?
      end

    private

      def api_unauthorized(message, bearer_error)
        headers["WWW-Authenticate"] = %(Bearer error="#{bearer_error}")
        render json: { message: }, status: :unauthorized
      end
    end
  end
end
