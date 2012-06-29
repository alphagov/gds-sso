class ExampleController < ApplicationController

  before_filter :authenticate_user!, :only => [:restricted, :this_requires_signin_permission]
  before_filter :require_signin_permission!, only: [:this_requires_signin_permission]

  def index
    render :text => "jabberwocky"
  end

  def restricted
    render :text => "restricted kablooie"
  end

  def this_requires_signin_permission
    render :text => "you have signin permission"
  end
end
