require 'active_support/concern'

module GDS
  module SSO
    module User
      extend ActiveSupport::Concern

      def self.below_rails_4?
        Gem.loaded_specs['rails'] && Gem.loaded_specs['rails'].version < Gem::Version.new("4.0")
      end

      included do
        if GDS::SSO::User.below_rails_4? && respond_to?(:attr_accessible)
          attr_accessible :uid, :email, :name, :permissions, :organisation_slug, :organisation_content_id, :disabled, as: :oauth
        end
      end

      def has_permission?(permission)
        if permissions
          permissions.include?(permission)
        end
      end

      def self.user_params_from_auth_hash(auth_hash)
        {
          'uid' => auth_hash['uid'],
          'email' => auth_hash['info']['email'],
          'name' => auth_hash['info']['name'],
          'permissions' => auth_hash['extra']['user']['permissions'],
          'organisation_slug' => auth_hash['extra']['user']['organisation_slug'],
          'organisation_content_id' => auth_hash['extra']['user']['organisation_content_id'],
          'disabled' => auth_hash['extra']['user']['disabled'],
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
          user = self.where(:uid => user_params['uid']).first ||
                 self.where(:email => user_params['email']).first

          if user
            if GDS::SSO::User.below_rails_4?
              user.update_attributes(user_params, as: :oauth)
            else
              user.update_attributes(user_params)
            end
            user
          else # Create a new user.
            if GDS::SSO::User.below_rails_4?
              self.create!(user_params, as: :oauth)
            else
              self.create!(user_params)
            end
          end
        end
      end
    end
  end
end
