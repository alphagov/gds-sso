require "rails"
require "spec_helper"

RSpec.describe GDS::SSO::Railtie do
  let(:cache) { double(:cache) }

  it "re-uses the Rails cache" do
    expect(GDS::SSO::Config.cache).to eq Rails.cache
  end
end
