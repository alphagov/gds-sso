require 'spec_helper'
require 'active_record'

describe Warden::SessionSerializer do
  class User < ActiveRecord::Base
    include GDS::SSO::User

  end

  before :each do
    @old_user_model = GDS::SSO::Config.user_model
    GDS::SSO::Config.user_model = User
    @user = double("User", uid: 1234)
    @serializer = Warden::SessionSerializer.new(nil)
  end
  after :each do
    GDS::SSO::Config.user_model = @old_user_model
  end

  describe "serializing a user" do

    it "should return the uid and a timestamp" do
      Timecop.freeze
      result = @serializer.serialize(@user)

      expect(result).to eq([1234, Time.now.utc])
    end

    it "should return nil if the user has no uid" do
      @user.stub(:uid).and_return(nil)
      result = @serializer.serialize(@user)

      expect(result).to be_nil
    end
  end

  describe "deserialize a user" do
    it "should return the user if the timestamp is current" do
      expect(User).to receive(:where).with(:uid => 1234, :remotely_signed_out => false).and_return(double(:first => :a_user))

      result = @serializer.deserialize [1234, Time.now.utc - GDS::SSO::Config.auth_valid_for + 3600]

      expect(result).to equal(:a_user)
    end

    it "should return nil if the timestamp is out of date" do
      expect(User).not_to receive(:where)

      result = @serializer.deserialize [1234, Time.now.utc - GDS::SSO::Config.auth_valid_for - 3600]

      expect(result).to be_nil
    end

    it "should return nil for a user without a timestamp" do
      expect(User).not_to receive(:where)

      result = @serializer.deserialize 1234

      expect(result).to be_nil
    end
  end
end
