require 'active_support/concern'

module GDS
  module SSO
    module User
      extend ActiveSupport::Concern

      included do
        if (Gem::Version.new(Rails.version) < Gem::Version.new("4.0")) && respond_to?(:attr_accessible)
          attr_accessible :uid, :email, :name, :permissions, :organisation_slug, as: :oauth
        end
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
          'organisation_slug'  => auth_hash['extra']['user']['organisation_slug'],
        }
      end

      def clear_remotely_signed_out!
        self.update_attribute(:remotely_signed_out, false)
      end

      def set_remotely_signed_out!
        self.update_attribute(:remotely_signed_out, true)
      end

      module ClassMethods
        def find_for_gds_oauth(auth_hash)
          user_params = GDS::SSO::User.user_params_from_auth_hash(auth_hash.to_hash)

          if user = self.where(:uid => auth_hash["uid"]).first
            if Gem::Version.new(Rails.version) >= Gem::Version.new("4.0")
              user.update_attributes(user_params)
            else
              user.update_attributes(user_params, as: :oauth)
            end
            user
          else # Create a new user.
            if Gem::Version.new(Rails.version) >= Gem::Version.new("4.0")
              self.create!(user_params)
            else
              self.create!(user_params, as: :oauth)
            end
          end
        end
      end
    end
  end
end
