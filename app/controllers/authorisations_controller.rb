class AuthorisationsController < ApplicationController
  skip_before_filter :require_signin_permission!

  def cant_signin
  end
end
