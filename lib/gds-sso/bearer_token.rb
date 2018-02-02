require 'multi_json'
require 'oauth2'

module GDS
  module SSO
    module BearerToken
      def self.locate(token_string)
        user_details = GDS::SSO::Config.cache.fetch(['api-user-cache', token_string], expires_in: 5.minutes) do
          access_token = OAuth2::AccessToken.new(oauth_client, token_string)
          response_body = access_token.get("/user.json?client_id=#{CGI.escape(GDS::SSO::Config.oauth_id)}").body
          omniauth_style_response(response_body)
        end

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
      # structure. Here we're addressing signon directly so
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
              'organisation_content_id' => input['organisation_content_id'],
            }
          }
        }
      end
    end

    module MockBearerToken
      def self.brute_force_permissions(permissions:)
        permissions << "signin" unless permissions.include?("signin")
        permissions << "internal_app" unless permissions.include?("internal_app")
        permissions
      end

      def self.locate(token_string)
        dummy_api_user = GDS::SSO.test_user || GDS::SSO::Config.user_klass.where(email: "dummyapiuser@domain.com").first
        if dummy_api_user.nil?
          dummy_api_user = GDS::SSO::Config.user_klass.new
          dummy_api_user.email = "dummyapiuser@domain.com"
          dummy_api_user.uid = "#{rand(10000)}"
          dummy_api_user.name = "Dummy API user created by gds-sso"
          dummy_api_user.permissions = ["signin", "internal_app"]
          dummy_api_user.save!
        end

        unless dummy_api_user.has_permission?("signin") && dummy_api_user.has_permission?("internal_app")
          permissions = dummy_api_user.permissions || []
          permissions = brute_force_permissions(permissions: permissions)
          dummy_api_user.update_attribute(:permissions, permissions)
        end

        dummy_api_user
      end
    end
  end
end
