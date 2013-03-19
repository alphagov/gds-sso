require 'rubygems'
require 'bundler'

# Yes, we really do want to turn off the test environment check here.
# Bad things happen if we don't ;-)
ENV['GDS_SSO_STRATEGY'] = 'real'

Bundler.require :default

require 'capybara/rspec'
require 'combustion'

Combustion.initialize!

require 'rspec/rails'
require 'capybara/rails'

require 'mechanize'
require 'capybara/mechanize'

include Warden::Test::Helpers

RSpec.configure do |config|
  config.mock_framework = :mocha
end

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}
