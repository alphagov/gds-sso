class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :only => :callback

  def callback
    redirect_to session["return_to"] || '/'
  end

  def sign_out
    cookie_key = Rails.application.config.session_options[:key]
    cookies.delete(cookie_key)
    reset_session
    redirect_to GDS::SSO::Config.oauth_root_url + "/users/sign_out"
  end
end
