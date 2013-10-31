class Api::UserController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!
  before_filter :require_user_update_permission

  def update
    user_json = JSON.parse(request.body.read)['user']
    oauth_hash = build_gds_oauth_hash(user_json)
    GDS::SSO::Config.user_klass.find_for_gds_oauth(oauth_hash)
    head :ok
  end

  def reauth
    user = GDS::SSO::Config.user_klass.where(:uid => params[:uid]).first
    if user.nil? || user.set_remotely_signed_out!
      head :ok
    else
      head 500
    end
  end

  private
    # This should mirror the object created by the omniauth-gds strategy/gem
    # By doing this, we can reuse the code for creating/updating the user
    def build_gds_oauth_hash(user_json)
      OmniAuth::AuthHash.new(
          uid: user_json['uid'],
          provider: 'gds',
          info: {
            name: user_json['name'],
            email: user_json['email']
          },
          extra: {
            user: {
              permissions: user_json['permissions'],
              organisations: user_json['organisations'],
            }
          })
    end

    def require_user_update_permission
      authorise_user!("user_update_permission")
    end
end
