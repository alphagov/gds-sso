RSpec.shared_examples "a gds-sso user class" do
  subject { described_class.new(uid: "12345") }

  it "implements #where" do
    expect(described_class).to respond_to(:where)

    result = described_class.where(uid: "123")
    expect(result).to respond_to(:first)
  end

  it "implements #update_attribute" do
    expect(subject).to respond_to(:update_attribute)

    subject.update_attribute(:remotely_signed_out, true)
    expect(subject).to be_remotely_signed_out
  end

  it "implements #update!" do
    subject.update!(email: "ab@c.com")
    expect(subject.email).to eq("ab@c.com")
  end

  it "implements #create!" do
    expect(described_class).to respond_to(:create!)
  end

  it "implements #remotely_signed_out?" do
    expect(subject).to respond_to(:remotely_signed_out?)
  end

  describe "#has_all_permissions?" do
    it "is false when there are no permissions" do
      subject.update!(permissions: nil)
      required_permissions = %w[signin]
      expect(subject.has_all_permissions?(required_permissions)).to be_falsy
    end

    it "is false when it does not have all required permissions" do
      subject.update!(permissions: %w[signin])
      required_permissions = %w[signin not_granted_permission_one not_granted_permission_two]
      expect(subject.has_all_permissions?(required_permissions)).to be false
    end

    it "is true when it has all required permissions" do
      subject.update!(permissions: %w[signin internal_app])
      required_permissions = %w[signin internal_app]
      expect(subject.has_all_permissions?(required_permissions)).to be true
    end
  end

  specify "the User class and GDS::SSO::User mixin work together" do
    auth_hash = {
      "uid" => "12345",
      "info" => {
        "name" => "Joe Smith",
        "email" => "joe.smith@example.com",
      },
      "extra" => {
        "user" => {
          "disabled" => false,
          "permissions" => %w[signin],
          "organisation_slug" => "cabinet-office",
          "organisation_content_id" => "91e57ad9-29a3-4f94-9ab4-5e9ae6d13588",
        },
      },
    }

    user = described_class.find_for_gds_oauth(auth_hash)
    expect(user).to be_an_instance_of(described_class)
    expect(user.uid).to eq("12345")
    expect(user.anonymous_user_id).to eq("a2681df3b83e7aa85")
    expect(user.name).to eq("Joe Smith")
    expect(user.email).to eq("joe.smith@example.com")
    expect(user).not_to be_disabled
    expect(user.permissions).to eq(%w[signin])
    expect(user.organisation_slug).to eq("cabinet-office")
    expect(user.organisation_content_id).to eq("91e57ad9-29a3-4f94-9ab4-5e9ae6d13588")
  end
end
