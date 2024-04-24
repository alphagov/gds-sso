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

  1000.times do |i|
    describe "configuring intercept_401_responses #{i}" do
      it "sets warden intercept_401 to false when the configuration option is set to false" do
        GDS::SSO::Config.intercept_401_responses = false

        described_class.initializers.each(&:run)

        expect(warden_manager.config[:intercept_401]).to be(false)
      end

      it "sets warden intercept_401 to true when the configuration option is set to true" do
        GDS::SSO::Config.intercept_401_responses = true

        described_class.initializers.each(&:run)

        expect(warden_manager.config[:intercept_401]).to be(true)
      end
    end
  end

  def warden_manager
    middleware = Rails.application.config.middleware.find { |m| m.name.include?("Warden::Manager") }

    Warden::Manager.new(nil, &middleware.block)
  end
end
