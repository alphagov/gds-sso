require 'active_support/concern'

module GDS::SSO::User
  extend ActiveSupport::Concern
  
  module ClassMethods
    def find_for_gds_oauth(auth_hash)
      if user = self.find_by_uid(auth_hash["uid"])
        user
      else # Create a user with a stub password. 
        user_params = auth_hash.dup.keep_if { |k,v| ['uid', 'email', 'name', 'version'].include?(k) }
        self.create!(user_params) 
      end
    end
  end
end