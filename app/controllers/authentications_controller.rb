class AuthenticationsController < ActionController::Base
  include GDS::SSO::ControllerMethods

  before_filter :authenticate_user!, :only => :callback
  skip_before_filter :require_signin_permission!
  layout false

  def callback
    redirect_to session["return_to"] || '/'
  end

  def failure

  end

  def sign_out
    logout
    redirect_to GDS::SSO::Config.oauth_root_url + "/users/sign_out"
  end
end
