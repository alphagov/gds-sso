require "spec_helper"
require "gds-sso/user"
require "gds-sso/lint/user_spec"

require "ostruct"

describe GDS::SSO::User do
  before :each do
    @auth_hash = {
      "provider" => "gds",
      "uid" => "abcde",
      "credentials" => { "token" => "abcdefg", "secret" => "abcdefg" },
      "info" => { "name" => "Matt Patterson", "email" => "matt@alphagov.co.uk" },
      "extra" => {
        "user" => {
          "permissions" => [], "organisation_slug" => nil, "organisation_content_id" => nil, "disabled" => false
        },
      },
    }
  end

  it "should extract the user params from the oauth hash" do
    expected = { "uid" => "abcde",
                 "name" => "Matt Patterson",
                 "email" => "matt@alphagov.co.uk",
                 "permissions" => [],
                 "organisation_slug" => nil,
                 "organisation_content_id" => nil,
                 "disabled" => false }
    expect(GDS::SSO::User.user_params_from_auth_hash(@auth_hash)).to eq(expected)
  end

  context "making sure that the lint spec is valid" do
    let(:described_class) { TestUser }
    it_behaves_like "a gds-sso user class"
  end
end
