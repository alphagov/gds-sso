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

  describe "configuring intercept_401_responses" do
    it "sets warden intercept_401 to false when the configuration option is set to false" do
      allow(GDS::SSO::Config).to receive(:intercept_401_responses).and_return(false)

      expect(warden_manager.config[:intercept_401]).to be(false)
    end

    it "sets warden intercept_401 to true when the configuration option is set to true" do
      allow(GDS::SSO::Config).to receive(:intercept_401_responses).and_return(true)

      expect(warden_manager.config[:intercept_401]).to be(true)
    end
  end

  def warden_manager
    middleware = Rails.application.config.middleware.find { |m| m.name.include?("Warden::Manager") }
    Warden::Manager.new(nil, &middleware.block)
  end
end
