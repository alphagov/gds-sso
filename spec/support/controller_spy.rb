class ControllerSpy < ApplicationController
  include GDS::SSO::ControllerMethods

  def initialize(current_user)
    @current_user = current_user
  end

  def authenticate_user!
    true
  end

  attr_reader :current_user
end
