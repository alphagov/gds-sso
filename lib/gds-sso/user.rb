require 'active_support/concern'

module GDS
  module SSO
    module User
      def included(base)
        attr_accessible :uid, :email, :name, :permissions, :organisation, as: :oauth
      end

      def has_permission?(permission)
        if permissions
          permissions.include?(permission)
        end
      end

      def self.user_params_from_auth_hash(auth_hash)
        {
          'uid'           => auth_hash['uid'],
          'email'         => auth_hash['info']['email'],
          'name'          => auth_hash['info']['name'],
          'permissions'   => auth_hash['extra']['user']['permissions'],
          'organisation'  => auth_hash['extra']['user']['organisation'],
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
          if user = self.where(:uid => auth_hash["uid"]).first
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
