require "spec_helper"
require "gds-sso/bearer_token"

describe GDS::SSO::BearerToken do
  describe ".locate" do
    it "creates a new user for a token" do
      response = double(body: {
        user: {
          uid: "asd",
          email: "user@example.com",
          name: "A Name",
          permissions: %w[signin],
          organisation_slug: "hmrc",
          organisation_content_id: "67a2b78d-eee3-45b3-80e2-792e7f71cecc",
        },
      }.to_json)

      allow_any_instance_of(OAuth2::AccessToken).to receive(:get).and_return(response)

      created_user = GDS::SSO::BearerToken.locate("MY-API-TOKEN")

      expect(created_user.email).to eql("user@example.com")

      same_user_again = GDS::SSO::BearerToken.locate("MY-API-TOKEN")

      expect(same_user_again.id).to eql(created_user.id)
    end

    it "returns nil for a nil token string" do
      expect(described_class.locate(nil)).to be_nil
    end

    it "returns nil for an empty token string" do
      expect(described_class.locate("")).to be_nil
    end
  end
end
