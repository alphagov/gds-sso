require 'warden'
require 'gds-sso/user'

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
    [user.uid, Time.now.utc]
  else
    nil
  end
end

Warden::Manager.serialize_from_session do |tuple|
  # This will reject old sessions that don't have an auth_set time
  uid, auth_set = tuple
  if auth_set and (auth_set + GDS::SSO::Config.auth_valid_for) > Time.now.utc
    GDS::SSO::Config.user_klass.where(:uid => uid, :remotely_signed_out => false).first
  else
    nil
  end
end

Warden::Strategies.add(:gds_sso) do
  def valid?
    ! ::GDS::SSO::ApiAccess.api_call?(env)
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

Warden::Strategies.add(:gds_bearer_token) do
  def valid?
    ::GDS::SSO::ApiAccess.api_call?(env) &&
      ::GDS::SSO::ApiAccess.oauth_api_call?(env)
  end

  def authenticate!
    logger.debug("Authenticating with gds_bearer_token strategy")

    begin
      access_token = OAuth2::AccessToken.new(oauth_client, token_from_authorization_header)
      response_body = access_token.get('/user.json').body
      user_details = omniauth_style_response(response_body)
      user = prep_user(user_details)
      success!(user)
    rescue OAuth2::Error
      custom!(unauthorized)
    end
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(
      GDS::SSO::Config.oauth_id,
      GDS::SSO::Config.oauth_secret,
      :site => GDS::SSO::Config.oauth_root_url
    )
  end

  def token_from_authorization_header
    env['HTTP_AUTHORIZATION'].gsub(/Bearer /, '')
  end

  # Our User code assumes we're getting our user data back
  # via omniauth and so receiving it in omniauth's preferred
  # structure. Here we're addressing signonotron directly so
  # we need to transform the response ourselves.
  #
  # There may be a way to simplify matters by having this
  # strategy work via omniauth too but I've not worked out how
  # to wire that up yet.
  def omniauth_style_response(response_body)
    input = MultiJson.decode(response_body)['user']

    {
      'uid' => input['uid'],
      'info' => {
        'email' => input['email'],
        'name' => input['name']
      },
      'extra' => {
        'user' => {
          'permissions' => input['permissions'],
          'organisation_slug' => input['organisation_slug'],
        }
      }
    }
  end

  def prep_user(auth_hash)
    user = GDS::SSO::Config.user_klass.find_for_gds_oauth(auth_hash)
    custom!(unauthorized) unless user
    user
  end

  def unauthorized
    [
      401,
      {
        'Content-Type' => 'text/plain',
        'Content-Length' => '0',
        'WWW-Authenticate' => %(Bearer error="invalid_token")
      },
      []
    ]
  end
end

Warden::Strategies.add(:mock_gds_sso) do
  def valid?
    ! ::GDS::SSO::ApiAccess.api_call?(env)
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

Warden::Strategies.add(:mock_gds_sso_api_access) do
  def valid?
    ::GDS::SSO::ApiAccess.api_call?(env)
  end

  def authenticate!
    logger.debug("Authenticating with mock_gds_sso_api_access strategy")
    dummy_api_user = GDS::SSO.test_user || GDS::SSO::Config.user_klass.where(email: "dummyapiuser@domain.com").first
    if dummy_api_user.nil?
      dummy_api_user = GDS::SSO::Config.user_klass.new(
          email: "dummyapiuser@domain.com",
          uid: "#{rand(10000)}",
          name: "Dummy API user created by gds-sso",
          as: :oauth)
      dummy_api_user.permissions = ["signin"]
      dummy_api_user.save!
    end
    success!(dummy_api_user)
  end
end
