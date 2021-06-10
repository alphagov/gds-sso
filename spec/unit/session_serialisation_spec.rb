require "spec_helper"
require "active_record"

describe Warden::SessionSerializer do
  before :each do
    @old_user_model = GDS::SSO::Config.user_model
    GDS::SSO::Config.user_model = SerializableUser
    @user = double("SerializableUser", uid: 1234)
    @serializer = Warden::SessionSerializer.new(nil)
  end
  after :each do
    GDS::SSO::Config.user_model = @old_user_model
  end

  describe "serializing a user" do
    it "should return the uid and an ISO 8601 string timestamp" do
      Timecop.freeze
      result = @serializer.serialize(@user)

      expect(result).to eq([1234, Time.now.utc.iso8601])
      expect(result.last).to be_a(String)
    end

    it "should return nil if the user has no uid" do
      allow(@user).to receive(:uid).and_return(nil)
      result = @serializer.serialize(@user)

      expect(result).to be_nil
    end
  end

  describe "deserialize a user" do
    it "should return the user if the timestamp is current and a Time" do
      expect(SerializableUser).to receive(:where).with(uid: 1234, remotely_signed_out: false).and_return(double(first: :a_user))

      result = @serializer.deserialize [1234, Time.now.utc - GDS::SSO::Config.auth_valid_for + 3600]

      expect(result).to equal(:a_user)
    end

    it "should return the user if the timestamp is current and is an ISO 8601 string" do
      expect(SerializableUser).to receive(:where).with(uid: 1234, remotely_signed_out: false).and_return(double(first: :a_user))

      result = @serializer.deserialize [1234, (Time.now.utc - GDS::SSO::Config.auth_valid_for + 3600).iso8601]

      expect(result).to equal(:a_user)
    end

    it "should return nil if the timestamp is out of date" do
      expect(SerializableUser).not_to receive(:where)

      result = @serializer.deserialize [1234, Time.now.utc - GDS::SSO::Config.auth_valid_for - 3600]

      expect(result).to be_nil
    end

    it "should return nil for a user without a timestamp" do
      expect(SerializableUser).not_to receive(:where)

      result = @serializer.deserialize 1234

      expect(result).to be_nil
    end

    it "should return nil for a user with a badly formatted timestamp" do
      expect(SerializableUser).not_to receive(:where)

      result = @serializer.deserialize [1234, "this is not a timestamp"]

      expect(result).to be_nil
    end
  end
end
