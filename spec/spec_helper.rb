# Yes, we really do want to turn off the test environment check here.
# Bad things happen if we don't ;-)
ENV["GDS_SSO_STRATEGY"] = "real"

require "capybara/rspec"
require "webmock/rspec"
require "combustion"

Combustion.initialize! :all do
  config.cache_store = :null_store
  config.action_dispatch.show_exceptions = :all
end

require "rspec/rails"
require "capybara/rails"
WebMock.disable_net_connect!

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].sort.each { |f| require f }

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, follow_redirects: false)
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.use_transactional_fixtures = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include ActiveSupport::Testing::TimeHelpers
  config.include Warden::Test::Helpers
  config.include Capybara::DSL
  config.include RequestHelpers, type: :request
end
