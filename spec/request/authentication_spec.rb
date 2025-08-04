require "spec_helper"

describe "AuthenticationController", type: :request do
  describe "GET /auth/gds/callback" do
    it "fails without a valid state param" do
      get "/auth/gds/callback"

      expect(response).to redirect_to("/auth/failure?message=csrf_detected&strategy=gds")
    end

    it "redirects to the attempted url if a user was restricted earlier in the session" do
      get "/restricted"

      state = request_to_establish_oauth_state

      stub_signon_oauth_token_request
      stub_successful_signon_user_request

      get "/auth/gds/callback?state=#{state}"
      expect(response).to redirect_to("/restricted")
    end

    it "redirects to the root path if the user hadn't tried to access a restricted url" do
      state = request_to_establish_oauth_state

      stub_signon_oauth_token_request
      stub_successful_signon_user_request

      get "/auth/gds/callback?state=#{state}"
      expect(response).to redirect_to("/")
    end

    it "uses the OAuth2 proof key for code exchange feature for increased security" do
      get "/auth/gds"

      expect(response).to have_http_status(:redirect)
      location = URI.parse(response.location)
      query = Rack::Utils.parse_query(location.query)

      expect(location.path).to eq("/oauth/authorize")
      expect(query).to include("code_challenge", "code_challenge_method")

      token_request = stub_request(:post, "http://signon/oauth/access_token")
                        .with(body: hash_including("code_verifier"))

      get "/auth/gds/callback?state=#{query['state']}"

      expect(token_request).to have_been_made
    end
  end

  describe "GET /auth/failure" do
    it "responds successfully" do
      get "/auth/failure"

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /auth/gds/sign_out" do
    it "redirects to signon sign out" do
      get "/auth/gds/sign_out"

      expect(response).to redirect_to("http://signon/users/sign_out")
    end

    it "logs an authenticated user out" do
      authenticate_with_stub_signon

      get "/auth/gds/sign_out"

      # access a restricted route to assert we're logged out
      get "/restricted"
      expect(response).to redirect_to("/auth/gds")
    end
  end
end
