class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, Array
  serialize :organisations, Array

  attr_accessible :uid, :email, :name, :permissions, :organisations, as: :oauth
end
