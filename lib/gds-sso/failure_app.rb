require "action_controller/metal"
require 'rails'

# Failure application that will be called every time :warden is thrown from
# any strategy or hook.
module GDS
  module SSO
    class FailureApp < ActionController::Metal
      include ActionController::UrlFor
      include ActionController::Redirecting
      include Rails.application.routes.url_helpers

      def self.call(env)
        if ::GDS::SSO::ApiAccess.valid_api_call?(env)
          [ 401, {'WWW-Authenticate' => %(Bearer error="invalid_token") }, [] ]
        else
          action(:redirect).call(env)
        end
      end

      def redirect
        store_location!
        redirect_to '/auth/gds'
      end

      # Stores requested uri to redirect the user after signing in. We cannot use
      # scoped session provided by warden here, since the user is not authenticated
      # yet, but we still need to store the uri based on scope, so different scopes
      # would never use the same uri to redirect.

      # TOTALLY NOT DOING THE SCOPE THING. PROBABLY SHOULD.
      def store_location!
        session["return_to"] = request.env['warden.options'][:attempted_path] if request.get?
      end

    end
  end
end
