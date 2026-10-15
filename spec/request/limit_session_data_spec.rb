require "spec_helper"

RSpec.describe "GDS-SSO session data limitation", type: :request do
  context "when a request would overflow the session cookie" do
    it "responds with 400 when the query string is oversized" do
      get "/auth/gds?payload=#{'A' * 6000}"

      expect(response).to have_http_status(:bad_request)
    end

    it "responds with 400 when the Referer header is oversized" do
      get "/auth/gds", headers: { "HTTP_REFERER" => "https://example.com/#{'A' * 6000}" }

      expect(response).to have_http_status(:bad_request)
    end

    it "responds with 400 when the origin param is oversized" do
      get "/auth/gds?origin=#{'A' * 6000}"

      expect(response).to have_http_status(:bad_request)
    end

    it "responds with 400 when several individually small values together exceed the limit" do
      get "/auth/gds?payload=#{'A' * 1300}", headers: { "HTTP_REFERER" => "https://example.com/#{'A' * 1300}" }

      expect(response).to have_http_status(:bad_request)
    end

    it "responds with 400 to oversized return_to paths" do
      get "/restricted?payload=#{'A' * 3000}"

      expect(response).to have_http_status(:bad_request)
    end

    it "does not write the oversized data into the session cookie" do
      get "/auth/gds?payload=#{'A' * 6000}"

      expect(response).to have_http_status(:bad_request)
      expect(response.headers["Set-Cookie"].to_s.bytesize).to be < ActionDispatch::Cookies::MAX_COOKIE_SIZE

      # Regular request; no replay of oversized session data
      get "/auth/gds"
      expect(response).to have_http_status(:redirect)
      expect(response.location).to start_with("http://signon/oauth/authorize")
    end
  end

  context "when a request does not overflow the session cookie" do
    it "redirects to signon, storing the query string, origin and state" do
      get "/auth/gds?app_param=1", headers: { "HTTP_REFERER" => "https://example.com/some-page" }

      expect(response).to have_http_status(:redirect)
      expect(URI.parse(response.location).path).to eq("/oauth/authorize")
      expect(session["omniauth.params"]).to eq("app_param" => "1")
      expect(session["omniauth.origin"]).to eq("https://example.com/some-page")
      expect(session["omniauth.state"]).to be_present
    end

    it "stores reasonably short return_to paths and redirects back to them" do
      get "/restricted"

      expect(response).to redirect_to("/auth/gds")
      expect(session["return_to"]).to eq("/restricted")

      state = request_to_establish_oauth_state
      stub_signon_oauth_token_request
      stub_successful_signon_user_request

      get "/auth/gds/callback?code=code&state=#{state}"

      expect(response).to redirect_to("/restricted")
    end

    it "does not limit the host applications's own session data" do
      get "/stuff-session", params: { size: 1500 }

      expect(response).to have_http_status(:success)
      expect(session["app_data"].bytesize).to eq(1500)
    end
  end

  context "when the host application causes an overflow" do
    it "responds with 500 when the app itself overflows the cookie" do
      get "/stuff-session", params: { size: 6000 }

      expect(response).to have_http_status(:internal_server_error)
    end
  end

  context "when the middleware is part of the stack" do
    it "wraps OmniAuth and Warden so it sees all session writes" do
      middlewares = Rails.application.middleware.middlewares.map(&:name)

      expect(middlewares.index("GDS::SSO::LimitSessionData")).to be < middlewares.index("OmniAuth::Builder")
      expect(middlewares.index("OmniAuth::Builder")).to be < middlewares.index("Warden::Manager")
    end
  end
end
