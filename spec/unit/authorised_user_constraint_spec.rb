require "spec_helper"
require "gds-sso/authorised_user_constraint"

describe GDS::SSO::AuthorisedUserConstraint do
  before do
    allow(GDS::SSO).to receive(:authenticate_user!).and_return(user)
    allow(GDS::SSO::AuthoriseUser).to receive(:call).and_return(true)
  end

  describe "#matches?" do
    let(:user) { TestUser.new }
    let(:warden) { instance_double("Warden::Proxy") }
    let(:request) { double("request", env: { "warden" => warden }) }

    it "authenticates the user" do
      expect(GDS::SSO).to receive(:authenticate_user!).with(warden)

      described_class.new(%w[signin]).matches?(request)
    end

    it "authorises the user" do
      expect(GDS::SSO::AuthoriseUser).to receive(:call).with(user, %w[signin])

      described_class.new(%w[signin]).matches?(request)
    end
  end
end
