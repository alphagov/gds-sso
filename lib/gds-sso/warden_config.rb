require "warden"
require "warden-oauth2"
require "gds-sso/bearer_token"

def logger
  Rails.logger || env["rack.logger"]
end

Warden::Manager.on_request do |proxy|
  proxy.env["gds_sso.api_call"] ||= ::GDS::SSO::ApiAccess.api_call?(proxy.env)
  proxy.env["gds_sso.api_bearer_token_present"] ||=
    proxy.env["gds_sso.api_call"] && !::GDS::SSO::ApiAccess.bearer_token(proxy.env).nil?
end

Warden::Manager.after_authentication do |user, _auth, _opts|
  # We've successfully signed in.
  # If they were remotely signed out, clear the flag as they're no longer suspended
  user.clear_remotely_signed_out!
end

Warden::Manager.serialize_into_session do |user|
  if user.respond_to?(:uid) && user.uid
    [user.uid, Time.now.utc.iso8601]
  end
end

Warden::Manager.serialize_from_session do |(uid, auth_timestamp)|
  # This will reject old sessions that don't have a previous login timestamp
  if auth_timestamp.is_a?(String)
    begin
      auth_timestamp = Time.parse(auth_timestamp)
    rescue ArgumentError
      auth_timestamp = nil
    end
  end

  if auth_timestamp && ((auth_timestamp + GDS::SSO::Config.auth_valid_for) > Time.now.utc)
    GDS::SSO::Config.user_klass.where(uid:, remotely_signed_out: false).first
  end
end

Warden::Strategies.add(:gds_sso) do
  def valid?
    !env["gds_sso.api_call"]
  end

  def authenticate!
    logger.debug("Authenticating with gds_sso strategy")

    if request.env["omniauth.auth"].nil?
      fail!("No credentials, bub")
    else
      user = prep_user(request.env["omniauth.auth"])
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

# We're using our own bearer token strategy rather than the one in Warden::OAuth2
# so that we can get a direct inverse of session strategies for valid?.
# It also allows us to avoid multiple DB queries to locate a user.
Warden::Strategies.add(:gds_bearer_token, Class.new(Warden::OAuth2::Strategies::Token)) do
  def valid?
    env["gds_sso.api_call"]
  end

  def token_string
    @token_string ||= GDS::SSO::ApiAccess.bearer_token(env)
  end

  def token
    return @token if defined? @token

    @token = Warden::OAuth2.config.token_model.locate(token_string)
    @token
  end
end

Warden::Strategies.add(:mock_gds_sso) do
  def valid?
    !env["gds_sso.api_call"]
  end

  def authenticate!
    logger.warn("Authenticating with mock_gds_sso strategy")

    test_user = GDS::SSO.test_user
    test_user ||= ENV["GDS_SSO_MOCK_INVALID"].present? ? nil : GDS::SSO::Config.user_klass.first
    if test_user
      # Brute force ensure test user has correct perms to signin
      unless test_user.has_permission?("signin")
        permissions = test_user.permissions || []
        test_user.update_attribute(:permissions, permissions << "signin")
      end
      success!(test_user)
    elsif Rails.env.test? && ENV["GDS_SSO_MOCK_INVALID"].present?
      fail!(:invalid)
    else
      raise "GDS-SSO running in mock mode and no test user found. Normally we'd load the first user in the database. Create a user in the database."
    end
  end
end
