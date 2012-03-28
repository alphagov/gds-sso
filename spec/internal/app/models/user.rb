class User

  def self.first
    # stub_user
    false
  end

  def self.stub_user
    OpenStruct.new({ :name => "User" })
  end


end