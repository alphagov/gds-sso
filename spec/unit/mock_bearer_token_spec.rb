require "spec_helper"
require "gds-sso/bearer_token"

describe GDS::SSO::MockBearerToken do
  describe ".locate" do
    it "returns a GDS::SSO.test_user if one is set" do
      test_user = TestUser.new
      allow(GDS::SSO).to receive(:test_user).and_return(test_user)

      expect(described_class.locate("anything")).to be(test_user)
    end

    it "doesn't modify the permissions of GDS::SSO.test_user" do
      test_user = TestUser.new(permissions: [])
      allow(GDS::SSO).to receive(:test_user).and_return(test_user)
      allow(GDS::SSO::Config).to receive(:permissions_for_dummy_api_user)
        .and_return(%w[signin extra_permission])

      expect(described_class.locate("anything")).to be(test_user)
      expect(test_user.permissions).not_to include("extra_permission")
    end

    it "returns a user with dummyapiuser@domain.com if one exists" do
      test_user = TestUser.new
      allow(GDS::SSO::Config).to receive(:user_klass).and_return(TestUser)
      allow(TestUser).to receive(:where).and_return([test_user])

      expect(described_class.locate("anything")).to be(test_user)
      expect(TestUser).to have_received(:where).with(email: "dummyapiuser@domain.com")
    end

    it "creates a user with dummyapiuser@domain.com if one does not exist" do
      allow(GDS::SSO::Config).to receive(:user_klass).and_return(TestUser)
      allow(GDS::SSO::Config).to receive(:additional_mock_permissions_required).and_return(nil)
      allow(TestUser).to receive(:where).and_return([])

      test_user = described_class.locate("anything")
      expect(test_user).to be_an_instance_of(TestUser)
      expect(test_user).to have_attributes(email: "dummyapiuser@domain.com",
                                           name: "Dummy API user created by gds-sso",
                                           permissions: %w[signin])
    end

    it "uses GDS::SSO::Config to overwrite any existing permissions" do
      test_user = TestUser.new(permissions: %w[signin other_permission])
      allow(GDS::SSO::Config).to receive(:user_klass).and_return(TestUser)
      allow(TestUser).to receive(:where).and_return([test_user])
      allow(GDS::SSO::Config).to receive(:permissions_for_dummy_api_user)
        .and_return(%w[signin extra_permission])

      test_user = described_class.locate("anything")
      expect(test_user.permissions).to match_array(%w[signin extra_permission])
    end
  end
end
