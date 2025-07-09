require "spec_helper"
require "gds-sso/api_access"
require "rack/mock_request"

describe GDS::SSO::ApiAccess do
  describe ".api_call?" do
    it "returns true GDS::SSO has been configured as api_only" do
      allow(GDS::SSO::Config).to receive(:api_only).and_return(true)

      expect(described_class.api_call?({})).to be(true)
    end

    it "returns true if the request matches the api_request_matcher" do
      allow(GDS::SSO::Config)
        .to receive(:api_request_matcher)
        .and_return(->(request) { request.path == "/api" })

      env = Rack::MockRequest.env_for("/api")
      expect(described_class.api_call?(env)).to be(true)
    end

    it "returns false if the request doesn't match the api_request_matcher" do
      allow(GDS::SSO::Config)
        .to receive(:api_request_matcher)
        .and_return(->(request) { request.path == "/api" })

      env = Rack::MockRequest.env_for("/other")
      expect(described_class.api_call?(env)).to be(false)
    end

    it "returns true if a bearer token is present" do
      env = { "HTTP_AUTHORIZATION" => "Bearer 1234:5678" }
      expect(described_class.api_call?(env)).to be(true)
    end

    it "returns false otherwise" do
      expect(described_class.api_call?({})).to be(false)
    end
  end

  describe ".bearer_token_present?" do
    it "returns true for a Bearer token in env HTTP_AUTHORIZATION" do
      env = { "HTTP_AUTHORIZATION" => "Bearer 1234:5678" }
      expect(described_class.bearer_token_present?(env)).to be(true)
    end

    it "returns false for a different value in env HTTP_AUTHORIZATION" do
      env = { "HTTP_AUTHORIZATION" => "Basic 1234:5678" }
      expect(described_class.bearer_token_present?(env)).to be(false)
    end

    it "returns false if HTTP_AUTHORIZATION is not set in env" do
      expect(described_class.bearer_token_present?({})).to be(false)
    end
  end
end
