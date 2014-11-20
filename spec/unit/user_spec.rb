require 'spec_helper'
require 'gds-sso/user'
require 'gds-sso/lint/user_spec'

require 'ostruct'

describe GDS::SSO::User do
  before :each do
    @auth_hash = {
      'provider' => 'gds',
      'uid' => 'abcde',
      'credentials' => {'token' => 'abcdefg', 'secret' => 'abcdefg'},
      'info' => {'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk'},
      'extra' => {'user' => {'permissions' => [], 'organisation_slug' => nil, 'disabled' => false}}
    }
  end

  it "should extract the user params from the oauth hash" do
    expected = {'uid' => 'abcde',
      'name' => 'Matt Patterson',
      'email' => 'matt@alphagov.co.uk',
      "permissions" => [],
      "organisation_slug" => nil,
      'disabled' => false,
    }
    expect(GDS::SSO::User.user_params_from_auth_hash(@auth_hash)).to eq(expected)
  end

  context "making sure that the lint spec is valid" do
    class TestUser < OpenStruct
      include GDS::SSO::User

      def self.where(opts)
        []
      end

      def self.create!(options, scope = {})
        new(options)
      end

      def update_attribute(key, value)
        send("#{key}=".to_sym, value)
      end

      def update_attributes(options)
        options.each do |key, value|
          update_attribute(key, value)
        end
      end

      def remotely_signed_out?
        remotely_signed_out
      end
    end

    let(:described_class) { TestUser }
    it_behaves_like "a gds-sso user class"
  end
end
