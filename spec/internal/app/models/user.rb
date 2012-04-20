class User
  include GDS::SSO::User

  def self.find_by_uid(something)
    stub_user
  end

  def self.first
    # stub_user
    false
  end

  def self.stub_user
    OpenStruct.new({ :uid => '1', :name => "User" })
  end


end
