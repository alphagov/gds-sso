require 'test_helper'
require 'json'
require 'gds-sso'
require 'gds-sso/omniauth_strategy'

class TestOmniAuthStrategy < Test::Unit::TestCase
  def setup
    @strategy = OmniAuth::Strategies::Gds.new(:gds, 'client_id', 'client_secret')
    @strategy.stubs(:fetch_user_data).returns({'user' => {'uid' => 'abcde', 'version' => 1, 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk', 'github' => 'fidothe', 'twitter' => 'fidothe'}}.to_json)
  end

  def test_basic_auth_hash_structure
    assert_equal 'Matt Patterson', @strategy.send(:build_auth_hash)['user_info']['name']
    assert_equal 'matt@alphagov.co.uk', @strategy.send(:build_auth_hash)['user_info']['email']
  end

  def test_extra_auth_hash_structure
    expected = {'uid' => 'abcde', 'version' => 1, 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk', 'github' => 'fidothe', 'twitter' => 'fidothe'}    
    assert_equal expected, @strategy.send(:build_auth_hash)['extra']['user_hash']
  end
end