class ControllerSpy < ApplicationController
  include GDS::SSO::ControllerMethods
  # rubocop:disable Lint/MissingSuper
  def initialize(current_user)
    @current_user = current_user
  end
  # rubocop:enable Lint/MissingSuper

  def authenticate_user!
    true
  end

  attr_reader :current_user
end
