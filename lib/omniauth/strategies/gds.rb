require "omniauth-oauth2"
require "multi_json"

class OmniAuth::Strategies::Gds < OmniAuth::Strategies::OAuth2
  uid { user["uid"] }

  info do
    {
      name: user["name"],
      email: user["email"],
    }
  end

  extra do
    {
      user: user,
      permissions: user["permissions"],
      organisation_slug: user["organisation_slug"],
      organisation_content_id: user["organisation_content_id"],
    }
  end

  def user
    @user ||= MultiJson.decode(access_token.get("/user.json?client_id=#{CGI.escape(options.client_id)}").body)["user"]
  end
end
