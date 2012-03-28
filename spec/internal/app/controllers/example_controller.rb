class ExampleController < ApplicationController

  before_filter :authenticate_user!

  def index
    redirect_to "http://google.com/"
    # require 'ruby-debug'
    # debugger
    render nothing: true
  end

end