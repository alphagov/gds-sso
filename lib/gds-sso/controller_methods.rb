module GDS
  module SSO
    module ControllerMethods
      def authenticate_user!
        request.env['warden'].authenticate!
      end

      def user_signed_in?
        request.env['warden'].authenticated?
      end

      def current_user
        request.env['warden'].authenticated? ? request.env['warden'].user : nil
      end

      def self.included(base)
        base.helper_method :user_signed_in?
        base.helper_method :current_user
      end
    end
  end
end