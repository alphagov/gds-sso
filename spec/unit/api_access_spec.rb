require "spec_helper"
require "gds-sso/api_access"

describe GDS::SSO::ApiAccess do
  context "with a bearer token" do
    it "it is considered an api call" do
      expect(GDS::SSO::ApiAccess.api_call?("HTTP_AUTHORIZATION" => "Bearer deadbeef12345678")).to be_truthy
    end
  end
end
