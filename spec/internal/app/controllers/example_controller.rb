class ExampleController < ApplicationController

  before_filter :authenticate_user!, :only => [:restricted]

  def index
    render :text => "jabberwocky"
  end

  def restricted
    render :text => "restricted kablooie"
  end
end
