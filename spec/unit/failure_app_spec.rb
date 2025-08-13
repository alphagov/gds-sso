require "spec_helper"

describe GDS::SSO::FailureApp, type: :request do
  describe "#redirect" do
    before do
      Rails.application.routes.draw do
        get "redirect", to: GDS::SSO::FailureApp.action(:redirect)
      end
    end

    after { Rails.application.reload_routes! }

    it "should store the return_to path in session when it is reasonably short" do
      attempted_path = "some-reasonably-short-path"

      get "/redirect", env: { "warden.options" => { attempted_path: } }

      expect(response).to redirect_to("/auth/gds")
      expect(session["return_to"]).to eq(attempted_path)
    end

    it "should not attempt to store the return_to path in session when it is very long" do
      attempted_path = "some-#{'very-' * 1000}-long-path"

      get "/redirect", env: { "warden.options" => { attempted_path: } }

      expect(response).to redirect_to("/auth/gds")
      expect(session["return_to"]).to be_nil
    end
  end
end
