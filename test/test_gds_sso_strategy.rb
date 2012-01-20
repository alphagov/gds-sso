require 'test_helper'
require 'json'
require 'gds-sso'
require 'gds-sso/omniauth_strategy'
require 'capybara/dsl'

class TestOmniAuthStrategy < Test::Unit::TestCase
  include OmniAuth::Test::StrategyTestCase
  include Capybara::DSL

  def strategy
    # return the parameters to a Rack::Builder map call:
    [OmniAuth::Strategies::Gds.new, 'client_id', 'client_secret']
  end

  def setup
    # post '/auth/gds_sso/callback', :user => { 'name' => 'Dylan', 'id' => '445' }
  end
end