require "spec_helper"

RSpec.describe "A system test" do
  context "when accessing a route that doesn't require permissions or authentication" do
    it "allows access" do
      visit "/not-restricted"
      expect(page).to have_content("jabberwocky")
    end
  end

  context "when accessing a route that requires authentication" do
    it "redirects an unauthenticated request to signon" do
      # This is done manually because we've got redirects turned following
      # switched off so we can handle an external redirect
      visit "/restricted"
      expect(page.response_headers["Location"]).to match("/auth/gds")
      visit page.response_headers["Location"]
      expect(page.response_headers["Location"]).to match("http://signon/oauth/authorize")
    end

    it "allows access for an authenticated user" do
      stub_signon_authenticated

      visit "/restricted"
      expect(page).to have_content("restricted kablooie")
    end

    it "restricts access if a user is authenticated but remotely signed out" do
      stub_signon_authenticated
      User.last.set_remotely_signed_out!

      visit "/restricted"
      expect(page.status_code).to eql(302)
      expect(page.response_headers["Location"]).to match("/auth/gds")
    end

    it "restricts access if a user is authenticated but session has expired" do
      stub_signon_authenticated

      Timecop.travel(Time.now.utc + GDS::SSO::Config.auth_valid_for + 5.minutes) do
        visit "/restricted"
        expect(page.status_code).to eql(302)
        expect(page.response_headers["Location"]).to match("/auth/gds")
      end
    end

    it "allows access when given a valid bearer token" do
      stub_signon_user_request
      page.driver.header("Authorization", "Bearer 123")

      visit "/restricted"
      expect(page).to have_content("restricted kablooie")
    end

    it "restricts access when given an invalid bearer token" do
      stub_request(:get, "http://signon/user.json?client_id=gds-sso-test")
        .to_return(status: 401)
      page.driver.header("Authorization", "Bearer 123")

      visit "/restricted"
      expect(page.status_code).to eq(401)
    end
  end

  context "when accessing a route that requires a permission" do
    it "allows access when an authenticated user has the permission" do
      stub_signon_authenticated(permissions: %w[execute])
      visit "/this-requires-execute-permission"
      expect(page).to have_content("you have execute permission")
    end

    it "restricts access when an authenticated user lacks the permission" do
      stub_signon_authenticated
      visit "/this-requires-execute-permission"
      expect(page.status_code).to eq(403)
    end
  end

  def stub_signon_authenticated(permissions: [])
    # visit restricted page to trigger redirect URL to record state attribute
    visit "/auth/gds"
    state = CGI.parse(URI.parse(page.response_headers["Location"]).query)
              .then { |query| query["state"].first }

    # Stub signon requests
    stub_request(:post, "http://signon/oauth/access_token")
      .to_return(body: { access_token: "token" }.to_json,
                 headers: { content_type: "application/json" })

    stub_signon_user_request(permissions: permissions)

    visit "/auth/gds/callback?code=code&state=#{state}"
  end

  def stub_signon_user_request(permissions: [])
    stub_request(:get, "http://signon/user.json?client_id=gds-sso-test")
      .to_return(
        body: {
          user: {
            uid: "123",
            email: "test-user@example.com",
            name: "Test User",
            permissions: permissions,
          },
        }.to_json,
        headers: { content_type: "application/json" },
      )
  end
end
