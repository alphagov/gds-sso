class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, Array

  attr_accessible :uid, :email, :name, :permissions, :organisation_slug, as: :oauth
end
