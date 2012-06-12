require 'test_helper'
require 'gds-sso/user'

class TestUser < Test::Unit::TestCase
  def setup
    @auth_hash = {
      'provider' => 'gds',
      'uid' => 'abcde',
      'credentials' => {'token' => 'abcdefg', 'secret' => 'abcdefg'},
      'info' => {'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk'},
      'extra' => {'user_hash' => {'uid' => 'abcde', 'version' => 1, 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk', 'github' => 'fidothe', 'twitter' => 'fidothe'}}
    }
  end

  def test_user_params_creation
    expected = {'uid' => 'abcde', 'version' => 1, 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk'}
    assert_equal expected, GDS::SSO::User.user_params_from_auth_hash(@auth_hash)
  end
end