RSpec.shared_examples "a gds-sso user class" do
  subject { described_class.new }

  it "implements #where" do
    expect(described_class).to respond_to(:where)

    result = described_class.where(uid: '123')
    expect(result).to respond_to(:first)
  end

  it "implements #update_attribute" do
    expect(subject).to respond_to(:update_attribute)

    subject.update_attribute(:remotely_signed_out, true)
    expect(subject).to be_remotely_signed_out
  end

  it "implements #update_attributes" do
    subject.update_attributes(email: "ab@c.com")
    expect(subject.email).to eq("ab@c.com")
  end

  it "implements #create!" do
    expect(described_class).to respond_to(:create!)
  end

  it "implements #remotely_signed_out?" do
    expect(subject).to respond_to(:remotely_signed_out?)
  end

  specify "the User class and GDS::SSO::User mixin work together" do
    auth_hash = {
      'uid' => '12345',
      'info' => {
        'name' => 'Joe Smith',
        'email' => 'joe.smith@example.com',
      },
      'extra' => {
        'user' => {
          'permissions' => ['signin'],
          'organisation_slug' => 'cabinet-office',
        }
      }
    }

    user = described_class.find_for_gds_oauth(auth_hash)
    expect(user).to be_an_instance_of(described_class)
    expect(user.name).to eq("Joe Smith")
    expect(user.email).to eq('joe.smith@example.com')
    expect(user.permissions).to eq(['signin'])
    expect(user.organisation_slug).to eq('cabinet-office')
  end
end
