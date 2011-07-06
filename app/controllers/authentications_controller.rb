class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :only => :callback
  def callback
    redirect_to session["return_to"]
  end
end