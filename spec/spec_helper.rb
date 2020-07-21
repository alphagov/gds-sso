# Yes, we really do want to turn off the test environment check here.
# Bad things happen if we don't ;-)
ENV["GDS_SSO_STRATEGY"] = "real"

require "bundler/setup"
require "combustion"
require "capybara/rspec"

Combustion.initialize! :all

require "rspec/rails"
require "capybara/rails"
require "mechanize"
require "capybara/mechanize"

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include(BackportControllerTestParams) if Rails.version < "5"
  config.include(Warden::Test::Helpers)
end
