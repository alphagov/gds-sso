module GDS
  module SSO
    class AuthoriseUser
      def self.call(...) = new(...).call

      def initialize(current_user, permissions)
        @current_user = current_user
        @permissions = permissions
      end

      def call
        case permissions
        when String
          unless current_user.has_permission?(permissions)
            raise GDS::SSO::PermissionDeniedError, "Sorry, you don't seem to have the #{permissions} permission for this app."
          end
        when Hash
          raise ArgumentError, "Must be either `any_of` or `all_of`" unless permissions.keys.size == 1

          if permissions[:any_of]
            authorise_user_with_at_least_one_of_permissions!(permissions[:any_of])
          elsif permissions[:all_of]
            authorise_user_with_all_permissions!(permissions[:all_of])
          else
            raise ArgumentError, "Must be either `any_of` or `all_of`"
          end
        end
      end

    private

      attr_reader :current_user, :permissions

      def authorise_user_with_at_least_one_of_permissions!(permissions)
        if permissions.none? { |permission| current_user.has_permission?(permission) }
          raise GDS::SSO::PermissionDeniedError,
                "Sorry, you don't seem to have any of the permissions: #{permissions.to_sentence} for this app."
        end
      end

      def authorise_user_with_all_permissions!(permissions)
        unless permissions.all? { |permission| current_user.has_permission?(permission) }
          raise GDS::SSO::PermissionDeniedError,
                "Sorry, you don't seem to have all of the permissions: #{permissions.to_sentence} for this app."
        end
      end
    end
  end
end
