require "rails"
require "spec_helper"

RSpec.describe GDS::SSO::Railtie do
  let(:cache) { double(:cache) }

  it "re-uses the Rails cache" do
    expect(GDS::SSO::Config.cache).to eq Rails.cache
  end

  it "honours API only setting" do
    expect(GDS::SSO::Config.api_only).to eq false
  end

  it "sets warden's intercept_401 value to the default config intercept_401_reponses value" do
    # it gets the warden manager from the middleware stack, set in gds-sso.rb
    manager = Warden::Manager.new(nil, &Rails.application.config.middleware.find { |m| m.name.include?("Warden::Manager") }.block)
    expect(manager.config[:intercept_401]).to eq true
  end
end
