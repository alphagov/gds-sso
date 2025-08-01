require "spec_helper"
require "gds-sso/api_access"
require "rack/mock_request"

describe GDS::SSO::ApiAccess do
  describe ".api_call?" do
    it "returns true if the rack env has already been tagged as an api_call" do
      expect(described_class.api_call?({ "gds_sso.api_call" => true })).to be(true)
    end

    it "returns false if the rack env has already been tagged as not an api_call" do
      expect(described_class.api_call?({ "gds_sso.api_call" => false })).to be(false)
    end

    it "returns true if GDS::SSO has been configured as api_only" do
      allow(GDS::SSO::Config).to receive(:api_only).and_return(true)

      expect(described_class.api_call?({})).to be(true)
    end

    context "when an api_request_matcher has been configured" do
      before do
        allow(GDS::SSO::Config)
          .to receive(:api_request_matcher)
          .and_return(->(request) { request.path == "/api" })
      end

      it "returns true if the request matches the api_request_matcher" do
        env = Rack::MockRequest.env_for("/api")
        expect(described_class.api_call?(env)).to be(true)
      end

      it "returns true if the request is for GDS SSO API at default location" do
        env = Rack::MockRequest.env_for("/auth/gds/api/#{SecureRandom.uuid}")
        expect(described_class.api_call?(env)).to be(true)
      end

      it "returns true if it matches a configured gds_sso_api_request_matcher" do
        allow(GDS::SSO::Config)
          .to receive(:gds_sso_api_request_matcher)
          .and_return(->(request) { request.path == "/special/gds-sso/route" })

        env = Rack::MockRequest.env_for("/special/gds-sso/route")
        expect(described_class.api_call?(env)).to be(true)
      end

      it "returns false if the request doesn't match the gds_sso_api_request_matcher or api_request_matcher" do
        allow(GDS::SSO::Config).to receive(:gds_sso_api_request_matcher).and_return(nil)

        env = Rack::MockRequest.env_for("/other")
        expect(described_class.api_call?(env)).to be(false)
      end
    end

    context "when an api_request_matcher has not been configured" do
      it "returns true if a bearer token is present" do
        env = { "HTTP_AUTHORIZATION" => "Bearer 1234:5678" }
        expect(described_class.api_call?(env)).to be(true)
      end

      it "returns false if nothing indicates an API call" do
        expect(described_class.api_call?({})).to be(false)
      end
    end
  end

  describe ".bearer_token" do
    it "returns a bearer token set in a HTTP_AUTHORIZATION header" do
      env = { "HTTP_AUTHORIZATION" => "Bearer 1234:5678" }
      expect(described_class.bearer_token(env)).to eq("1234:5678")
    end

    it "returns nil for an empty bearer token in the HTTP_AUTHORIZATION header" do
      env = { "HTTP_AUTHORIZATION" => "Bearer " }
      expect(described_class.bearer_token(env)).to be_nil
    end

    it "supports all the authorization headers configured in Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS" do
      Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |header|
        env = { header => "Bearer 1234" }
        expect(described_class.bearer_token(env)).to eq("1234")
      end
    end

    it "returns nil if a bearer token isn't set" do
      expect(described_class.bearer_token({})).to be_nil
    end
  end
end
