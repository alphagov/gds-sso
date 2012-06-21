require 'active_support/concern'

module GDS
  module SSO
    class ApiUser
      def uid
        0
      end

      def name
        'API User'
      end
    end

    module User
      def has_permission?(scope, permission)
        # NOTE: this line is a temporary helper until we have migrated users over to having permissions.
        return true if permissions.has_key?("everything") && permissions["everything"][0] == "signin"

        if permissions.has_key?(scope)
          permissions[scope].include?(permission) || permissions[scope].include?("admin")
        end
      end

      def self.user_params_from_auth_hash(auth_hash)
        {
          'uid'         => auth_hash['uid'],
          'email'       => auth_hash['info']['email'],
          'name'        => auth_hash['info']['name'],
          'permissions' => auth_hash['extra']['user']['permissions']
        }
      end

      extend ActiveSupport::Concern

      module ClassMethods
        def find_for_gds_oauth(auth_hash)
          if user = self.find_by_uid(auth_hash["uid"])
            user.update_attributes(GDS::SSO::User.user_params_from_auth_hash(auth_hash), as: :oauth)
            user
          else # Create a new user.
            self.create!(GDS::SSO::User.user_params_from_auth_hash(auth_hash), as: :oauth)
          end
        end
      end
    end
  end
end
