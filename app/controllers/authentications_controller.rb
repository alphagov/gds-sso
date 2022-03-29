class AuthenticationsController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_action :authenticate_user!, only: :callback
  layout false

  def callback
    redirect_to session["return_to"] || "/"
  end

  def failure; end

  def sign_out
    logout
    redirect_to "#{GDS::SSO::Config.oauth_root_url}/users/sign_out", allow_other_host: true
  end
end
