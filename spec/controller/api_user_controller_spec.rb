require "spec_helper"

def user_update_json
  {
    "user" => {
      "uid" => @user_to_update.uid,
      "name" => "Joshua Marshall",
      "email" => "user@domain.com",
      "permissions" => ["signin", "new permission"],
      "organisation_slug" => "justice-league"
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

    @signon_sso_push_user = User.create!({
        :uid => "a1s2d3#{rand(10000)}",
        :email => "ssopushuser@legit.com",
        :name => "SSO Push user",
        :permissions => ["signin", "user_update_permission"] },
        as: :oauth)
  end

  describe "PUT update" do
    it "should deny access to anybody but the API user (or a user with 'user_update_permission')" do
      malicious_user = User.new({
          :uid => '2',
          :name => "User",
          :permissions =>["signin"] })

      request.env['warden'] = double("stub warden", :authenticate! => true, authenticated?: true, user: malicious_user)

      request.env['RAW_POST_DATA'] = user_update_json
      put :update, uid: @user_to_update.uid

      expect(response.status).to eq(403)
    end

    it "should create/update the user record in the same way as the OAuth callback" do
      # Test that it authenticates
      request.env['warden'] = double("mock warden")
      expect(request.env['warden']).to receive(:authenticate!).at_least(:once).and_return(true)
      expect(request.env['warden']).to receive(:authenticated?).at_least(:once).and_return(true)
      expect(request.env['warden']).to receive(:user).at_least(:once).and_return(@signon_sso_push_user)

      request.env['RAW_POST_DATA'] = user_update_json
      put :update, uid: @user_to_update.uid

      @user_to_update.reload
      expect(@user_to_update.name).to eq("Joshua Marshall")
      expect(@user_to_update.email).to eq("user@domain.com")
      expect(@user_to_update.permissions).to eq(["signin", "new permission"])
      expect(@user_to_update.organisation_slug).to eq("justice-league")
    end
  end

  describe "POST reauth" do
    it "should deny access to anybody but the API user (or a user with 'user_update_permission')" do
      malicious_user = User.new({
          :uid => '2',
          :name => "User",
          :permissions => ["signin"] })

      request.env['warden'] = double("stub warden", :authenticate! => true, authenticated?: true, user: malicious_user)

      post :reauth, uid: @user_to_update.uid

      expect(response.status).to eq(403)
    end

    it "should return success if user record doesn't exist" do
      request.env['warden'] = double("mock warden")
      expect(request.env['warden']).to receive(:authenticate!).at_least(:once).and_return(true)
      expect(request.env['warden']).to receive(:authenticated?).at_least(:once).and_return(true)
      expect(request.env['warden']).to receive(:user).at_least(:once).and_return(@signon_sso_push_user)

      post :reauth, uid: "nonexistent-user"

      expect(response.status).to eq(200)
    end

    it "should set remotely_signed_out to true on the user" do
      # Test that it authenticates
      request.env['warden'] = double("mock warden")
      expect(request.env['warden']).to receive(:authenticate!).at_least(:once).and_return(true)
      expect(request.env['warden']).to receive(:authenticated?).at_least(:once).and_return(true)
      expect(request.env['warden']).to receive(:user).at_least(:once).and_return(@signon_sso_push_user)

      post :reauth, uid: @user_to_update.uid

      @user_to_update.reload
      expect(@user_to_update.remotely_signed_out).to be_true
    end
  end
end
