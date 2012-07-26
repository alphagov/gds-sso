require_relative 'test_helper'

class SessionSerialisationTest < Test::Unit::TestCase
  class User
    include GDS::SSO::User

  end

  def setup
    @old_user_model = GDS::SSO::Config.user_model
    GDS::SSO::Config.user_model = "SessionSerialisationTest::User"
    @user = stub("User", uid: 1234)
    @serializer = Warden::SessionSerializer.new(nil)
  end
  def teardown
    Timecop.return
    GDS::SSO::Config.user_model = @old_user_model
  end

  def test_serializing_a_user_returns_the_uid_and_a_timestamp
    Timecop.freeze
    result = @serializer.serialize(@user)

    assert_equal [1234, Time.now.utc], result
  end

  def test_deserializing_a_user_and_in_date_timestamp_returns_the_user
    User.expects(:find_by_uid).with(1234).returns(:a_user)

    result = @serializer.deserialize [1234, Time.now.utc - GDS::SSO::Config.auth_valid_for + 3600]

    assert_equal :a_user, result
  end

  def test_deserializing_a_user_and_out_of_date_timestamp_returns_nil
    User.expects(:find_by_uid).never

    result = @serializer.deserialize [1234, Time.now.utc - GDS::SSO::Config.auth_valid_for - 3600]

    assert_equal nil, result
  end

  def test_deserializing_a_user_without_a_timestamp_returns_nil
    User.expects(:find_by_uid).never

    result = @serializer.deserialize 1234

    assert_equal nil, result
  end
end
