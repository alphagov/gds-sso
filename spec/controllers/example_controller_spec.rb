require_relative '../spec_helper'

describe ExampleController do

  describe "when not signed in" do

    it "redirects to the sign in page" do
      get :index, { }, :test => "true"

      puts response.body
      response.status.should == 301
    end

  end

end