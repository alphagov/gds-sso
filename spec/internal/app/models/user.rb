class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, type: Array
end
