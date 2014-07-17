require 'multi_json'
require 'oauth2'

module GDS
  module SSO
    module BearerToken
      def self.locate(token_string)
        access_token = OAuth2::AccessToken.new(oauth_client, token_string)
        response_body = access_token.get("/user.json?client_id=#{CGI.escape(GDS::SSO::Config.oauth_id)}").body
        user_details = omniauth_style_response(response_body)
        GDS::SSO::Config.user_klass.find_for_gds_oauth(user_details)
      rescue OAuth2::Error
        nil
      end

      def self.oauth_client
        @oauth_client ||= OAuth2::Client.new(
          GDS::SSO::Config.oauth_id,
          GDS::SSO::Config.oauth_secret,
          :site => GDS::SSO::Config.oauth_root_url
        )
      end

      # Our User code assumes we're getting our user data back
      # via omniauth and so receiving it in omniauth's preferred
      # structure. Here we're addressing signonotron directly so
      # we need to transform the response ourselves.
      def self.omniauth_style_response(response_body)
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
    end

    module MockBearerToken
      def self.locate(token_string)
        dummy_api_user = GDS::SSO.test_user || GDS::SSO::Config.user_klass.where(email: "dummyapiuser@domain.com").first
        if dummy_api_user.nil?
          dummy_api_user = GDS::SSO::Config.user_klass.new
          dummy_api_user.email = "dummyapiuser@domain.com"
          dummy_api_user.uid = "#{rand(10000)}"
          dummy_api_user.name = "Dummy API user created by gds-sso"
          dummy_api_user.permissions = ["signin"]
          dummy_api_user.save!
        end
        dummy_api_user
      end
    end
  end
end
