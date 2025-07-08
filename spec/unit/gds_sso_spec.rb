require "spec_helper"

describe GDS::SSO do
  describe "#authenticate_user!" do
    let(:user) { TestUser.new }
    let(:warden) do
      instance_double("Warden::Proxy",
                      authenticate!: true,
                      authenticated?: false,
                      user:)
    end

    context "when a user is authenticated" do
      it "authenticates the user and returns the user object" do
        expect(described_class.authenticate_user!(warden)).to be(user)
        expect(warden).to have_received(:authenticate!)
      end
    end

    context "when a user is already authenticated and not remotely signed out" do
      it "doesn't reauthenticate the user" do
        allow(warden).to receive(:authenticated?).and_return(true)
        expect(described_class.authenticate_user!(warden)).to be(user)

        expect(warden).not_to have_received(:authenticate!)
      end
    end

    context "when a user is already authenticated and remotely signed out" do
      it "authenticates the user again" do
        user.remotely_signed_out = true
        expect(described_class.authenticate_user!(warden)).to be(user)
        expect(warden).to have_received(:authenticate!)
      end
    end
  end
end
