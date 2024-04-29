require "spec_helper"

RSpec.describe GDS::SSO::ControllerMethods do
  describe "#authorise_user!" do
    let(:current_user) { double }
    let(:expected_error) { GDS::SSO::PermissionDeniedError }

    context "when the user is authorised" do
      it "does not raise an error" do
        allow(current_user).to receive(:has_permission?).with("good").and_return(true)

        expect { ControllerSpy.new(current_user).authorise_user!("good") }.not_to raise_error
      end
    end

    context "when the user is not authorised" do
      it "raises an error" do
        allow(current_user).to receive(:has_permission?).with("bad").and_return(false)

        expect { ControllerSpy.new(current_user).authorise_user!("bad") }.to raise_error(expected_error)
      end
    end
  end
end
