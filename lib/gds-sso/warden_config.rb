require 'warden'
require 'warden-oauth2'
require 'gds-sso/bearer_token'

def logger
  if Rails.logger # if we are actually running in a rails app
    Rails.logger
  else
    env['rack.logger']
  end
end

Warden::Manager.after_authentication do |user, auth, opts|
  # We've successfully signed in.
  # If they were remotely signed out, clear the flag as they're no longer suspended
  user.clear_remotely_signed_out!
end

Warden::Manager.serialize_into_session do |user|
  if user.respond_to?(:uid) and user.uid
    [user.uid, Time.now.utc.iso8601]
  else
    nil
  end
end

Warden::Manager.serialize_from_session do |(uid, auth_timestamp)|
  # This will reject old sessions that don't have a previous login timestamp
  if auth_timestamp.is_a?(String)
    auth_timestamp = begin
      Time.parse(auth_timestamp)
    rescue ArgumentError
      nil
    end
  end

  if auth_timestamp and (auth_timestamp + GDS::SSO::Config.auth_valid_for) > Time.now.utc
    GDS::SSO::Config.user_klass.where(:uid => uid, :remotely_signed_out => false).first
  else
    nil
  end
end

Warden::Strategies.add(:gds_sso) do
  def valid?
    ! ::GDS::SSO::ApiAccess.valid_api_call?(env)
  end

  def authenticate!
    logger.debug("Authenticating with gds_sso strategy")

    if request.env['omniauth.auth'].nil?
      fail!("No credentials, bub")
    else
      user = prep_user(request.env['omniauth.auth'])
      success!(user)
    end
  end

  private

  def prep_user(auth_hash)
    user = GDS::SSO::Config.user_klass.find_for_gds_oauth(auth_hash)
    fail!("Couldn't process credentials") unless user
    user
  end
end

Warden::OAuth2.configure do |config|
  config.token_model = GDS::SSO::Config.use_mock_strategies? ? GDS::SSO::MockBearerToken : GDS::SSO::BearerToken
end
Warden::Strategies.add(:gds_bearer_token, Warden::OAuth2::Strategies::Bearer)

Warden::Strategies.add(:mock_gds_sso) do
  def valid?
    ! ::GDS::SSO::ApiAccess.valid_api_call?(env)
  end

  def authenticate!
    logger.warn("Authenticating with mock_gds_sso strategy")

    test_user = GDS::SSO.test_user
    test_user ||= ENV['GDS_SSO_MOCK_INVALID'].present? ? nil : GDS::SSO::Config.user_klass.first
    if test_user
      # Brute force ensure test user has correct perms to signin
      if ! test_user.has_permission?("signin")
        permissions = test_user.permissions || []
        test_user.update_attribute(:permissions, permissions << "signin")
      end
      success!(test_user)
    else
      if Rails.env.test? && ENV['GDS_SSO_MOCK_INVALID'].present?
        fail!(:invalid)
      else
        raise "GDS-SSO running in mock mode and no test user found. Normally we'd load the first user in the database. Create a user in the database."
      end
    end
  end
end
