class User < OpenStruct
  include GDS::SSO::User

  def self.find_by_uid(something)
    stub_user
  end

  def self.first
    # stub_user
    false
  end

  def self.stub_user
    User.new({ :uid => '1', :name => "User", :permissions => { "GDS_SSO integration test" => ["signin"] } })
  end

  def update_attributes(*args)
  end
end
