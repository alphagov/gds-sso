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

  describe "#anonymous_user_id" do
    it "should be nil if ANONYMOUS_USER_ID_SECRET is unset" do
      ClimateControl.modify ANONYMOUS_USER_ID_SECRET: nil do
        expect(TestUser.new.anonymous_user_id).to be_nil
      end
    end

    it "should be computed based on the uid and ANONYMOUS_USER_ID_SECRET" do
      ClimateControl.modify ANONYMOUS_USER_ID_SECRET: "some-anonymous-user-id-secret" do
        expect("8724f603978a3adc0").to eq(TestUser.new(uid: "some-user-id").anonymous_user_id)
        expect("69d0cf995988be2e1").to eq(TestUser.new(uid: "some-other-user-id").anonymous_user_id)
      end

      ClimateControl.modify ANONYMOUS_USER_ID_SECRET: "other-anonymous-user-id-secret" do
        expect("297069f42a9251c64").to eq(TestUser.new(uid: "some-user-id").anonymous_user_id)
        expect("4a3c66e26f5ec4229").to eq(TestUser.new(uid: "other-user-id").anonymous_user_id)
      end
    end
  end

  context "making sure that the lint spec is valid" do
    let(:described_class) { TestUser }
    it_behaves_like "a gds-sso user class"
  end
end
