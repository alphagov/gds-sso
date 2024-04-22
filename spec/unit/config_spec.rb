require "spec_helper"

describe GDS::SSO::Config do
  describe "#permissions_for_dummy_user" do
    context "with no additional mock permissions" do
      it "returns signin" do
        subject.additional_mock_permissions_required = nil
        expect(subject.permissions_for_dummy_api_user).to eq(%w[signin])
      end
    end

    context "with an additional mock permission as a string" do
      it "returns an array of permissions" do
        subject.additional_mock_permissions_required = "internal_app"
        expected_permissions = %w[signin internal_app]
        expect(subject.permissions_for_dummy_api_user).to eq(expected_permissions)
      end
    end

    context "with additional mock permissions as an array" do
      it "returns an array of permissions" do
        subject.additional_mock_permissions_required = %w[another_permission yet_another_permission]
        expected_permissions = %w[signin another_permission yet_another_permission]
        expect(subject.permissions_for_dummy_api_user).to eq(expected_permissions)
      end
    end
  end

  describe ".intercept_401_responses" do
    it "defaults to true" do
      expect(subject.intercept_401_responses).to eq(true)
    end
  end
end
