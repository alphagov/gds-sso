require 'omniauth/oauth'
require 'multi_json'

# Authenticate to GDS with OAuth 2.0 and retrieve
# basic user information.
#
# @example Basic Usage
#     use OmniAuth::Builder :gds, 'API Key', 'Secret Key'

class OmniAuth::Strategies::Gds < OmniAuth::Strategies::OAuth2

  # @param [Rack Application] app standard middleware application parameter
  # @param [String] api_key the application id as [provided by GDS]
  # @param [String] secret_key the application secret as [provided by Bitly]
  def initialize(app, api_key = nil, secret_key = nil, options = {}, &block)
    client_options = {
      :site => "#{GDS::SSO::Config.oauth_root_url}/",
      :authorize_url => "#{GDS::SSO::Config.oauth_root_url}/oauth/authorize",
      :token_url => "#{GDS::SSO::Config.oauth_root_url}/oauth/access_token",
      :access_token_url => "#{GDS::SSO::Config.oauth_root_url}/oauth/access_token",
      :ssl => {
        :verify => false
      }
    }

    super(app, :gds, api_key, secret_key, client_options, options, &block)
  end

  def call(env)
    if GDS::SSO::ApiAccess.api_call?(env)
      @app.call(env)
    else
      super
    end
  end

  protected

  def fetch_user_data
    @access_token.get('/user.json').body
  end

  def user_hash
    @user_hash ||= MultiJson.decode(fetch_user_data)['user']
  end

  def build_auth_hash
    {'uid' => user_hash['uid'], 'user_info' => {'name' => user_hash['name'], 'email' => user_hash['email']}, 'extra' => {'user_hash' => user_hash}}
  end

  def auth_hash
    OmniAuth::Utils.deep_merge(super, build_auth_hash)
  end
end
