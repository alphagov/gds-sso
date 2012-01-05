require 'warden'
require 'omniauth/oauth'

Warden::Manager.serialize_into_session do |user|
  user.uid
end

Warden::Manager.serialize_from_session do |uid|
  GDS::SSO::Config.user_klass.find_by_uid(uid)
end

Warden::Strategies.add(:gds_sso) do
  def valid?
    true
  end

  def authenticate!
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

Warden::Strategies.add(:mock_gds_sso) do
  def valid?
    true
  end

  def authenticate!
    test_user = GDS::SSO.test_user || GDS::SSO::Config.user_klass.first
    if test_user
      success!(test_user)
    else
      raise "GDS-SSO running in mock mode and no test user found. Normally we'd load the first user in the database. Create a user in the database."
    end
  end
end
