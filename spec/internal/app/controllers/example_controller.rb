class ExampleController < ApplicationController

  before_filter :authenticate_user!, :only => [:restricted, :this_requires_signin_permission]
  before_filter :require_signin_permission!, only: [:this_requires_signin_permission]

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
