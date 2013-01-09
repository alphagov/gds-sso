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

      def has_permission?(permission)
        true
      end

      def clear_remotely_signed_out!
      end

      def set_remotely_signed_out!
      end

      def remotely_signed_out?
        false
      end
    end

    module User
      def included(base)
        attr_accessible :uid, :email, :name, :permissions, as: :oauth
      end

      def has_permission?(permission)
        if permissions
          if permissions.is_a?(Hash)
            raise "GDS::SSO no longer supports a Hash for permissions. Array expected. Maybe you need to migrate?"
          end

          permissions.include?(permission) || permissions.include?("admin")
        end
      end

      def self.user_params_from_auth_hash(auth_hash)
        if auth_hash['extra']['user']['permissions'].is_a?(Hash)
          # Until Signon emits an array of permissions, we need to support legacy Hash.
          # Once Signon has been changed, we can drop support for Hash.
          permissions_array = auth_hash['extra']['user']['permissions'].values.first
        else
          permissions_array = auth_hash['extra']['user']['permissions']
        end
        {
          'uid'         => auth_hash['uid'],
          'email'       => auth_hash['info']['email'],
          'name'        => auth_hash['info']['name'],
          'permissions' => permissions_array
        }
      end

      def clear_remotely_signed_out!
        self.update_attribute(:remotely_signed_out, false)
      end

      def set_remotely_signed_out!
        self.update_attribute(:remotely_signed_out, true)
      end

      extend ActiveSupport::Concern

      module ClassMethods
        def find_for_gds_oauth(auth_hash)
          if user = self.find_by_uid(auth_hash["uid"])
            user.update_attributes(GDS::SSO::User.user_params_from_auth_hash(auth_hash.to_hash), as: :oauth)
            user
          else # Create a new user.
            self.create!(GDS::SSO::User.user_params_from_auth_hash(auth_hash.to_hash), as: :oauth)
          end
        end
      end
    end
  end
end
