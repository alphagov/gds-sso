require 'warden'
require 'omniauth/oauth'

Warden::Manager.serialize_into_session do |user|
  user.respond_to?(:uid) ? user.uid : nil
end

Warden::Manager.serialize_from_session do |uid|
  GDS::SSO::Config.user_klass.find_by_uid(uid)
end

Warden::Strategies.add(:gds_sso) do
  def valid?
    ! ::GDS::SSO::ApiAccess.api_call?(env)
  end

  def authenticate!
    Rails.logger.debug("Authenticating with gds_sso strategy")

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

Warden::Strategies.add(:gds_sso_api_access) do
  def valid?
    ::GDS::SSO::ApiAccess.api_call?(env)
  end
  
  def authenticate!
    Rails.logger.debug("Authenticating with gds_sso_api_access strategy")

    if ! basic_auth_configured?
      Rails.logger.debug("Basic auth not configured, not requiring authentication")
      success!('api')
    end
    
    auth = Rack::Auth::Basic::Request.new(env)

    return custom!(unauthorized) unless auth.provided?
    return fail!(:bad_request) unless auth.basic?
  
    if valid_api_user?(*auth.credentials)
      success!(auth.credentials[0])
    else
      custom!(unauthorized)
    end
  end
  
  def basic_auth_configured?
    ! ::GDS::SSO::Config.basic_auth_user.nil?
  end
  
  def valid_api_user?(username, password)
    username.to_s.strip != '' && 
      password.to_s.strip != '' && 
      username == ::GDS::SSO::Config.basic_auth_user &&
      password == ::GDS::SSO::Config.basic_auth_password
  end
  
  def unauthorized
    [
      401,
      {
        'Content-Type' => 'text/plain',
        'Content-Length' => '0',
        'WWW-Authenticate' => %(Basic realm="#{GDS::SSO::Config.basic_auth_realm}")
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
    Rails.logger.debug("Authenticating with mock_gds_sso strategy")
    test_user = GDS::SSO.test_user || GDS::SSO::Config.user_klass.first
    if test_user
      success!(test_user)
    else
      raise "GDS-SSO running in mock mode and no test user found. Normally we'd load the first user in the database. Create a user in the database."
    end
  end
end

Warden::Strategies.add(:mock_gds_sso_api_access) do
  def valid?
    ::GDS::SSO::ApiAccess.api_call?(env)
  end
  
  def authenticate!
    Rails.logger.debug("Authenticating with mock_gds_sso_api_access strategy")
    success!(GDS::SSO.test_user || GDS::SSO::Config.user_klass.first)
  end
end
