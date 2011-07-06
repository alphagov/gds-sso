module GDS
  module SSO
    module Config
      # Name of the User class
      mattr_accessor :user
      @@user = "User"
      
      def self.user_klass
        user.to_s.constantize
      end
    end
  end
end