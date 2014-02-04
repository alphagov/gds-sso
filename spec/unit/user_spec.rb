require 'spec_helper'
require 'gds-sso/user'

describe GDS::SSO::User do
  before :each do
    @auth_hash = {
      'provider' => 'gds',
      'uid' => 'abcde',
      'credentials' => {'token' => 'abcdefg', 'secret' => 'abcdefg'},
      'info' => {'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk'},
      'extra' => {'user' => {'permissions' => [], 'organisation_slug' => nil}}
    }
  end

  it "should extract the user params from the oauth hash" do
    expected = {'uid' => 'abcde', 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk', "permissions" => [], "organisation_slug" => nil}
    expect(GDS::SSO::User.user_params_from_auth_hash(@auth_hash)).to eq(expected)
  end
end
