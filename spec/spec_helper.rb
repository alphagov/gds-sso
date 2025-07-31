# Yes, we really do want to turn off the test environment check here.
# Bad things happen if we don't ;-)
ENV["GDS_SSO_STRATEGY"] = "real"

require "webmock/rspec"
require "combustion"

Combustion.initialize! :all do
  config.cache_store = :null_store
  config.action_dispatch.show_exceptions = :all
end

require "rspec/rails"
WebMock.disable_net_connect!

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].sort.each { |f| require f }

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
  config.include RequestHelpers, type: :request
  config.before(:each, type: :request) do
    # we reload routes each test as GDS::SSO::Config affects what routes are
    # available, we only want to run this once routes are loaded otherwise
    # we can lose app routes
    routes_reloader = Rails.application.routes_reloader

    # Routes changed in Rails 8 to be lazily loaded so this wasn't a problem
    # before Rails 8.
    # TODO: remove this line once Rails 7 support is removed
    next unless routes_reloader.respond_to?(:loaded)

    routes_reloader.reload! if routes_reloader.loaded
  end
end
