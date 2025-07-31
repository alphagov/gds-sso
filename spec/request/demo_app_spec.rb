require "spec_helper"

describe "Integration tests with a demo app", type: :request do
  describe "accessing a route that doesn't require authentication" do
    it "allows access" do
      get "/not-restricted"
      expect(response).to have_http_status(:success)
      expect(response.body).to eq("jabberwocky")
    end
  end

  describe "accessing a route the requires authentication" do
    context "when GDS::SSO isn't configured to treat this as an explicit API request" do
      it "redirects an unauthenticated request to sign-in" do
        get "/restricted"
        expect(response).to redirect_to("/auth/gds")
      end

      it "responds successfully for an authenticated user" do
        authenticate_with_stub_signon

        get "/restricted"
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("restricted kablooie")
      end

      it "redirects to sign-in if a user is authenticated but remotely signed out" do
        authenticate_with_stub_signon
        User.last.set_remotely_signed_out!

        get "/restricted"
        expect(response).to redirect_to("/auth/gds")
      end

      it "redirects to sign-in if a user's session has expired" do
        authenticate_with_stub_signon

        travel_to(Time.now.utc + GDS::SSO::Config.auth_valid_for + 1.second) do
          get "/restricted"
          expect(response).to redirect_to("/auth/gds")
        end
      end

      it "allows access when given a valid bearer token" do
        stub_successful_signon_user_request

        get "/restricted", headers: { "Authorization" => "Bearer 123" }
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("restricted kablooie")
      end

      it "restricts access when given an invalid bearer token" do
        stub_failed_signon_user_request

        get "/restricted", headers: { "Authorization" => "Bearer invalid" }
        expect(response).to have_http_status(:unauthorized)
        expect_invalid_bearer_token_response(response)
      end
    end

    context "when an application is configured as API only" do
      before { allow(GDS::SSO::Config).to receive(:api_only).and_return(true) }

      it "allows access when given a valid bearer token" do
        stub_successful_signon_user_request

        get "/restricted", headers: { "Authorization" => "Bearer 123" }
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("restricted kablooie")
      end

      it "rejects a request without a bearer token" do
        get "/restricted"
        expect(response).to have_http_status(:unauthorized)
        expect_missing_bearer_token_response(response)
      end

      it "restricts access for an invalid bearer token" do
        stub_failed_signon_user_request

        get "/restricted", headers: { "Authorization" => "Bearer invalid" }
        expect(response).to have_http_status(:unauthorized)
        expect_invalid_bearer_token_response(response)
      end
    end

    context "when API requests are differentiated by api_request_matcher" do
      it "treats a match as an API request" do
        allow(GDS::SSO::Config)
          .to receive(:api_request_matcher)
          .and_return(->(request) { request.path == "/restricted" })

        get "/restricted"
        expect(response).to have_http_status(:unauthorized)
        expect_missing_bearer_token_response(response)
      end

      it "treats a non-match as a non-API request" do
        allow(GDS::SSO::Config)
          .to receive(:api_request_matcher)
          .and_return(->(_request) { false })

        get "/restricted"
        expect(response).to redirect_to("/auth/gds")
      end
    end
  end

  describe "when accessing routes without authentication and using the mock strategies" do
    before { use_mock_strategies }

    it "allows a user access without authentication" do
      # non-bearer token mock requests require a user to exist
      User.create!(
        uid: SecureRandom.uuid,
        email: "user@example.com",
        name: "Example User",
        permissions: [],
      )

      get "/restricted"
      expect(response).to have_http_status(:success)
      expect(response.body).to eq("restricted kablooie")
    end

    it "can be configured to fail authentication with an env var" do
      ClimateControl.modify("GDS_SSO_MOCK_INVALID" => "1") do
        get "/restricted"
        expect(response).to redirect_to("/auth/gds")
      end
    end

    it "allows an API request without a bearer token" do
      allow(GDS::SSO::Config).to receive(:api_only).and_return(true)

      get "/restricted"
      expect(response).to have_http_status(:success)
      expect(response.body).to eq("restricted kablooie")
    end

    it "can be configured to fail API authentication with an env var" do
      allow(GDS::SSO::Config).to receive(:api_only).and_return(true)

      ClimateControl.modify("GDS_SSO_MOCK_INVALID" => "1") do
        get "/restricted"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "when accessing a route that requires permission" do
    context "when GDS::SSO isn't configured to treat this as an explicit API request" do
      it "allows a user with the permission to access the resource" do
        authenticate_with_stub_signon(permissions: %w[execute])

        get "/this-requires-execute-permission"
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("you have execute permission")
      end

      it "restricts a user lacking the permission" do
        authenticate_with_stub_signon

        get "/this-requires-execute-permission"
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("Sorry, you don&#39;t seem to have the execute permission for this app.")
      end
    end

    context "when GDS::SSO is configured to treat the request as an API request" do
      before { allow(GDS::SSO::Config).to receive(:api_only).and_return(true) }

      it "allows a user with the permission to access the resource" do
        stub_successful_signon_user_request(permissions: %w[execute])

        get "/this-requires-execute-permission", headers: { "Authorization" => "Bearer 123" }
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("you have execute permission")
      end

      it "restricts a user lacking the permission" do
        stub_successful_signon_user_request

        get "/this-requires-execute-permission", headers: { "Authorization" => "Bearer 123" }
        expect(response).to have_http_status(:forbidden)
        expect_json_response(response, { "message" => "Sorry, you don't seem to have the execute permission for this app." })
      end
    end

    context "when using bearer token for auth with the mock strategy" do
      before { use_mock_strategies }

      it "automatically grants permissions configured in GDS:SSO::Config.additional_mock_permissions_required" do
        allow(GDS::SSO::Config).to receive(:additional_mock_permissions_required).and_return(%w[execute])

        stub_successful_signon_user_request

        get "/this-requires-execute-permission", headers: { "Authorization" => "Bearer 123" }
        expect(response).to have_http_status(:success)
        expect(response.body).to eq("you have execute permission")
      end

      it "doesn't grant access without that config" do
        allow(GDS::SSO::Config).to receive(:additional_mock_permissions_required).and_return(nil)

        stub_successful_signon_user_request

        get "/this-requires-execute-permission", headers: { "Authorization" => "Bearer 123" }
        expect(response).to have_http_status(:forbidden)
        expect_json_response(response, { "message" => "Sorry, you don't seem to have the execute permission for this app." })
      end
    end
  end

  context "when accessing a route that is restricted by the authorised user constraint" do
    it "allows access when an authenticated user has correct permissions" do
      authenticate_with_stub_signon(permissions: %w[constraint])

      get "/constraint-restricted"
      expect(response).to have_http_status(:success)
      expect(response.body).to eq("constraint restricted")
    end

    it "redirects an unauthenticated request to signon" do
      get "/constraint-restricted"

      expect(response).to redirect_to("/auth/gds")
    end

    it "restricts access when an authenticated user does not have the correct permissions" do
      authenticate_with_stub_signon

      get "/constraint-restricted"
      expect(response).to have_http_status(:forbidden)
    end
  end

  def expect_missing_bearer_token_response(response)
    expect(response.headers).to include("WWW-Authenticate" => 'Bearer error="invalid_request"')
    expect_json_response(response, { "message" => "No bearer token was provided" })
  end

  def expect_invalid_bearer_token_response(response)
    expect(response.headers).to include("WWW-Authenticate" => 'Bearer error="invalid_token"')
    expect_json_response(response, { "message" => "Bearer token does not appear to be valid" })
  end

  def expect_json_response(response, json)
    expect(response.media_type).to eq("application/json")
    expect(response.parsed_body).to eq(json)
  end

  def use_mock_strategies
    # Using allow_any_instance_of because it's hard to access the instance
    # of the class used within the Rails middleware
    allow_any_instance_of(Warden::Config).to receive(:[]).and_call_original
    allow_any_instance_of(Warden::Config)
      .to receive(:[])
      .with(:default_strategies)
      .and_return({ _all: %i[mock_gds_sso gds_bearer_token] })

    allow(Warden::OAuth2.config).to receive(:token_model).and_return(GDS::SSO::MockBearerToken)
  end
end
