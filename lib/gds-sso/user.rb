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
      def self.user_params_from_auth_hash(auth_hash)
        {'uid' => auth_hash['uid'], 'email' => auth_hash['info']['email'], 'name' => auth_hash['info']['name'], 'version' => auth_hash['extra']['user_hash']['version']}
      end

      extend ActiveSupport::Concern

      module ClassMethods
        def find_for_gds_oauth(auth_hash)
          if user = self.find_by_uid(auth_hash["uid"])
            user
          else # Create a new user.
            self.create!(GDS::SSO::User.user_params_from_auth_hash(auth_hash))
          end
        end
      end
    end
  end
end