require "spec_helper"

def user_update_json
  {
    "user" => { 
      "uid" => @user_to_update.uid, 
      "name" => "Joshua Marshall", 
      "email" => "user@domain.com", 
      "permissions" => ["signin", "new permission"]
    }
  }.to_json
end

def legacy_user_update_json
  {
    "user" => { 
      "uid" => @user_to_update.uid, 
      "name" => "Joshua Marshall", 
      "email" => "user@domain.com", 
      "permissions" => {
        "GDS_SSO integration test" => ["signin", "new permission"]
      }
    }
  }.to_json
end

describe Api::UserController, type: :controller do

  before :each do
    @user_to_update = User.create!({ 
        :uid => "a1s2d3#{rand(10000)}", 
        :email => "old@domain.com",
        :name => "Moshua Jarshall", 
        :permissions => ["signin"] }, 
        as: :oauth)
  end

  describe "PUT update" do
    it "should deny access to anybody but the API user (or a user with 'user_update_permission')" do
      malicious_user = User.new({ 
          :uid => '2', 
          :name => "User", 
          :permissions =>["signin"] })

      request.env['warden'] = stub("stub warden", :authenticate! => true, authenticated?: true, user: malicious_user)

      request.env['RAW_POST_DATA'] = user_update_json
      put :update, uid: @user_to_update.uid
      
      assert_equal 403, response.status
    end

    it "should create/update the user record in the same way as the OAuth callback" do
      # Test that it authenticates
      request.env['warden'] = mock("mock warden")
      request.env['warden'].expects(:authenticate!).at_least_once.returns(true)
      request.env['warden'].expects(:authenticated?).at_least_once.returns(true)
      request.env['warden'].expects(:user).at_least_once.returns(GDS::SSO::ApiUser.new)

      request.env['RAW_POST_DATA'] = user_update_json
      put :update, uid: @user_to_update.uid

      @user_to_update.reload
      assert_equal "Joshua Marshall", @user_to_update.name
      assert_equal "user@domain.com", @user_to_update.email
      expected_permissions = ["signin", "new permission"]
      assert_equal expected_permissions, @user_to_update.permissions
    end

    it "should support the legacy user JSON" do
      request.env['warden'] = mock("mock warden")
      request.env['warden'].expects(:authenticate!).at_least_once.returns(true)
      request.env['warden'].expects(:authenticated?).at_least_once.returns(true)
      request.env['warden'].expects(:user).at_least_once.returns(GDS::SSO::ApiUser.new)

      request.env['RAW_POST_DATA'] = legacy_user_update_json
      put :update, uid: @user_to_update.uid

      @user_to_update.reload
      assert_equal "Joshua Marshall", @user_to_update.name
      assert_equal "user@domain.com", @user_to_update.email
      expected_permissions = ["signin", "new permission"]
      assert_equal expected_permissions, @user_to_update.permissions
    end
  end

  describe "POST reauth" do
    it "should deny access to anybody but the API user (or a user with 'user_update_permission')" do
      malicious_user = User.new({ 
          :uid => '2', 
          :name => "User", 
          :permissions => ["signin"] })

      request.env['warden'] = stub("stub warden", :authenticate! => true, authenticated?: true, user: malicious_user)

      post :reauth, uid: @user_to_update.uid
      
      assert_equal 403, response.status
    end

    it "should set remotely_signed_out to true on the user" do
      # Test that it authenticates
      request.env['warden'] = mock("mock warden")
      request.env['warden'].expects(:authenticate!).at_least_once.returns(true)
      request.env['warden'].expects(:authenticated?).at_least_once.returns(true)
      request.env['warden'].expects(:user).at_least_once.returns(GDS::SSO::ApiUser.new)

      post :reauth, uid: @user_to_update.uid

      @user_to_update.reload
      assert_equal true,  @user_to_update.remotely_signed_out
    end
  end
end
