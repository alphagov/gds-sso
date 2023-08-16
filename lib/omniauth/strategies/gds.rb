require "omniauth-oauth2"
require "json"

class OmniAuth::Strategies::Gds < OmniAuth::Strategies::OAuth2
  uid { user["uid"] }

  option :pkce, true

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
    @user ||= JSON.parse(access_token.get("/user.json?client_id=#{CGI.escape(options.client_id)}").body).fetch("user")
  end
end
