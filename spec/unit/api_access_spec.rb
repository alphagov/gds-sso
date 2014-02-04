require 'spec_helper'
require 'gds-sso/api_access'

describe GDS::SSO::ApiAccess do
  it "should not consider IE7 accept header as an api call" do
    ie7_accept_header = 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, ' +
      'application/x-shockwave-flash, application/xaml+xml, application/x-ms-xbap, ' +
      'application/x-ms-application, */*'
    expect(GDS::SSO::ApiAccess.api_call?('HTTP_ACCEPT' => ie7_accept_header)).to be_false
  end

  it "should consider a json accept header to be an api call" do
    expect(GDS::SSO::ApiAccess.api_call?('HTTP_ACCEPT' => 'application/json')).to be_true
  end

  it "should consider a request with an authorization header to be an oauth api call" do
    expect(GDS::SSO::ApiAccess.oauth_api_call?('HTTP_AUTHORIZATION' => 'Bearer blahblahblah')).to be_true
  end

  it "should not consider a request with HTTP basic auth to be an oauth api call" do
    expect(GDS::SSO::ApiAccess.oauth_api_call?('HTTP_AUTHORIZATION' => 'Basic Some basic credentials')).to be_false
  end

  it "should not consider a request with an empty authorization header to be an oauth api call" do
    expect(GDS::SSO::ApiAccess.oauth_api_call?('HTTP_AUTHORIZATION' => '')).to be_false
  end
end
