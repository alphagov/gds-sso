require "spec_helper"

def user_update_json
  {
    "user" => { 
      "uid" => "a1s2d3", 
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
    @user_to_update = User.new({ 
        :uid => 'a1s2d3', 
        :name => "Moshua Jarshall", 
        :permissions => { "GDS_SSO integration test" => ["signin"] } })
  end

  describe "PUT update" do
    it "should deny access to anybody but the API user (or a user with 'user_update_permission')" do
      malicious_user = User.new({ 
          :uid => '2', 
          :name => "User", 
          :permissions => { "GDS_SSO integration test" => ["signin"] } })

      request.env['warden'] = stub("stub warden", :authenticate! => true, authenticated?: true, user: malicious_user)

      request.env['RAW_POST_DATA'] = user_update_json
      put :update, uid: @user_to_update.uid
      
      assert_equal 403, response.status
    end

    it "should create/update the user record in the same way as the OAuth callback" do
      # Test that it authenticates
      request.env['warden'] = mock("stub warden", authenticated?: true, user: GDS::SSO::ApiUser.new)
      request.env['warden'].expects(:authenticate!).at_least_once.returns(true)

      @user_to_update.expects(:update_attributes).with({ 
          "uid" => "a1s2d3",
          "name" => "Joshua Marshall", 
          "email" => "user@domain.com", 
          "permissions" => { "GDS_SSO integration test" => ["signin", "new permission"] }}, as: :oauth)

      User.expects(:find_by_uid).with("a1s2d3").returns(@user_to_update)

      request.env['RAW_POST_DATA'] = user_update_json
      put :update, uid: @user_to_update.uid
    end
  end
end
