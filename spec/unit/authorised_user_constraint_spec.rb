require "spec_helper"
require "gds-sso/authorised_user_constraint"

describe GDS::SSO::AuthorisedUserConstraint do
  before do
    allow(GDS::SSO::AuthoriseUser).to receive(:call).and_return(true)
  end

  describe "#matches?" do
    let(:user) { double("user", remotely_signed_out?: remotely_signed_out) }
    let(:warden) do
      double(
        "warden",
        authenticated?: user_authenticated,
        user:,
        authenticate!: nil,
      )
    end
    let(:user_authenticated) { true }
    let(:remotely_signed_out) { false }
    let(:request) { double("request", env: { "warden" => warden }) }

    it "authorises the user" do
      expect(GDS::SSO::AuthoriseUser).to receive(:call).with(warden.user, %w[signin])
      expect(warden).not_to receive(:authenticate!)

      described_class.new(%w[signin]).matches?(request)
    end

    context "when the user is not authenticated" do
      let(:user_authenticated) { false }

      it "authenticates the user" do
        expect(warden).to receive(:authenticate!)

        described_class.new(%w[signin]).matches?(request)
      end
    end

    context "when the user is remotely signed out" do
      let(:remotely_signed_out) { true }

      it "authenticates the user" do
        expect(warden).to receive(:authenticate!)

        described_class.new(%w[signin]).matches?(request)
      end
    end
  end
end
