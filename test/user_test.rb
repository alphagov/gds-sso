require 'test_helper'
require 'gds-sso/user'

class TestUser < Test::Unit::TestCase
  def setup
    @auth_hash = {
      'provider' => 'gds',
      'uid' => 'abcde',
      'credentials' => {'token' => 'abcdefg', 'secret' => 'abcdefg'},
      'info' => {'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk'},
      'extra' => {'user' => {'permissions' => [], 'organisations' => []}}
    }
  end

  def test_user_params_creation
    expected = {'uid' => 'abcde', 'name' => 'Matt Patterson', 'email' => 'matt@alphagov.co.uk', "permissions" => [], "organisations" => []}
    assert_equal expected, GDS::SSO::User.user_params_from_auth_hash(@auth_hash)
  end
end
