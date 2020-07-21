class ExampleController < ApplicationController
  before_action :authenticate_user!, only: %i[restricted this_requires_signin_permission]

  def index
    render body: "jabberwocky"
  end

  def restricted
    render body: "restricted kablooie"
  end

  def this_requires_signin_permission
    render body: "you have signin permission"
  end
end
