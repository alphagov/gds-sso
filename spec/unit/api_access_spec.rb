require 'spec_helper'
require 'gds-sso/api_access'

describe GDS::SSO::ApiAccess do
  describe "api_call?" do
    context "with application/json accept header" do
      it "is considered an api call" do
        expect(GDS::SSO::ApiAccess.api_call?('HTTP_ACCEPT' => 'application/json')).to be_truthy
      end
    end

    context "without application/json accept header" do
      it "is not considered an api call" do
        expect(GDS::SSO::ApiAccess.api_call?('HTTP_ACCEPT' => 'text/html')).to be_falsey
      end
    end

    it "should not consider IE7 accept header as an api call" do
      ie7_accept_header = 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, ' +
        'application/x-shockwave-flash, application/xaml+xml, application/x-ms-xbap, ' +
        'application/x-ms-application, */*'
      expect(GDS::SSO::ApiAccess.api_call?('HTTP_ACCEPT' => ie7_accept_header)).to be_falsey
    end
  end

  describe "valid_api_call?" do
    let(:headers) { { 'HTTP_ACCEPT' => 'application/json' } }

    context "with a bearer token" do
      let(:valid_headers) { headers.merge('HTTP_AUTHORIZATION' => 'Bearer deadbeef12345678') }

      it "is considered a valid api call" do
        expect(GDS::SSO::ApiAccess.valid_api_call?(valid_headers)).to be_truthy
      end
    end

    context "without a bearer token" do
      it "is not considered a valid api call" do
        expect(GDS::SSO::ApiAccess.valid_api_call?(headers)).to be_falsey
      end
    end

    context "without a valid HTTP_ACCEPT header" do
      it "is not considered a valid api call" do
        expect(GDS::SSO::ApiAccess.valid_api_call?('HTTP_AUTHORIZATION' => 'Bearer deadbeef12345678')).to be_falsey
      end
    end
  end
end
