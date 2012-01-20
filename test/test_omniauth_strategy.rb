require 'test_helper'
require 'json'
require 'gds-sso'
require 'gds-sso/omniauth_strategy'

class TestOmniAuthStrategy < Test::Unit::TestCase
  def setup
    @app = stub("app")
    @strategy = OmniAuth::Strategies::Gds.new(@app, :gds, 'client_id', 'client_secret')
    @strategy.stubs(:fetch_user_data).returns({'user' => {'uid' => 'abcde', 'version' => 1, 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk', 'github' => 'fidothe', 'twitter' => 'fidothe'}}.to_json)
  end

  def test_build_auth_hash_returns_name_and_email
    assert_equal 'Matt Patterson', @strategy.send(:build_auth_hash)['user_info']['name']
    assert_equal 'matt@alphagov.co.uk', @strategy.send(:build_auth_hash)['user_info']['email']
  end

  def test_build_auth_hash_contains_extra_info
    expected = {'uid' => 'abcde', 'version' => 1, 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk', 'github' => 'fidothe', 'twitter' => 'fidothe'}
    assert_equal expected, @strategy.send(:build_auth_hash)['extra']['user_hash']
  end

  def test_oauth_bypassed_if_json_is_accepted_by_request
    @app.expects(:call)
    rack_env = { "HTTP_ACCEPT" => 'application/json' }
    @strategy.call(rack_env)
  end
end