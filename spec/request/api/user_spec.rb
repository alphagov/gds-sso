require "spec_helper"

describe "Api::UserController", type: :request do
  shared_examples "rejects a request from an unauthenticated user" do |method, path|
    it "rejects the request when a user is unauthenticated" do
      stub_failed_signon_user_request
      public_send(method, path, headers: { "Authorization" => "Bearer anything" })
      expect(response).to have_http_status(:unauthorized)
    end
  end

  shared_examples "rejects a request from an authenticated user lacking permission" do |method, path|
    it "rejects the request when a user is authenticated but lacking permission" do
      stub_successful_signon_user_request(permissions: [])
      public_send(method, path, headers: { "Authorization" => "Bearer anything" })
      expect(response).to have_http_status(:forbidden)
    end
  end

  shared_examples "operates as an API endpoint if api_request_matcher doesn't match it" do |method, path|
    it "doesn't redirect to /auth/gds because it's recognised as an API request" do
      allow(GDS::SSO::Config)
        .to receive(:api_request_matcher)
        .and_return(->(_request) { false })

      stub_failed_signon_user_request
      public_send(method, path, headers: { "Authorization" => "Bearer anything" })
      expect(response.media_type).to eq("application/json")
    end
  end

  shared_examples "redirects to /auth/gds if gds_sso_api_request_matcher is configured to not match" do |method, path|
    it "fails if gds_sso_api_request_matcher is configured to not match" do
      allow(GDS::SSO::Config)
        .to receive(:api_request_matcher)
        .and_return(->(_request) { false })

      allow(GDS::SSO::Config)
        .to receive(:gds_sso_api_request_matcher)
        .and_return(nil)

      public_send(method, path, headers: { "Authorization" => "Bearer anything" })
      expect(response).to redirect_to("/auth/gds")
    end
  end

  describe "PUT /auth/gds/api/users/:uid" do
    shared_params = [:put, "/auth/gds/api/users/#{SecureRandom.uuid}"]
    it_behaves_like "rejects a request from an unauthenticated user", *shared_params
    it_behaves_like "rejects a request from an authenticated user lacking permission", *shared_params
    it_behaves_like "operates as an API endpoint if api_request_matcher doesn't match it", *shared_params
    it_behaves_like "redirects to /auth/gds if gds_sso_api_request_matcher is configured to not match", *shared_params

    it "updates an existing user" do
      stub_successful_signon_user_request(permissions: %w[user_update_permission])

      user = User.create!(
        uid: SecureRandom.uuid,
        email: "user@example.com",
        name: "Example User",
        permissions: [],
      )

      put "/auth/gds/api/users/#{user.uid}",
          headers: { "Authorization" => "Bearer anything" },
          params: user_update_params(user, { "name" => "John Matrix" }),
          as: :json

      expect(response).to have_http_status(:success)
      expect(response.body).to eq("")
      expect(user.reload.name).to eq("John Matrix")
    end

    it "creates a new user if a user does not exist" do
      stub_successful_signon_user_request(permissions: %w[user_update_permission])

      user = User.new(
        uid: SecureRandom.uuid,
        email: "user@example.com",
        name: "Example User",
        permissions: [],
      )

      put "/auth/gds/api/users/#{user.uid}",
          headers: { "Authorization" => "Bearer anything" },
          params: user_update_params(user),
          as: :json

      expect(response).to have_http_status(:success)
      expect(response.body).to eq("")
      expect(User.last.uid).to eq(user.uid)
    end
  end

  describe "POST /auth/gds/api/users/:uid/reauth" do
    shared_params = [:post, "/auth/gds/api/users/#{SecureRandom.uuid}/reauth"]
    it_behaves_like "rejects a request from an unauthenticated user", *shared_params
    it_behaves_like "rejects a request from an authenticated user lacking permission", *shared_params
    it_behaves_like "operates as an API endpoint if api_request_matcher doesn't match it", *shared_params
    it_behaves_like "redirects to /auth/gds if gds_sso_api_request_matcher is configured to not match", *shared_params

    it "flags a user that exists as remotely signed out" do
      stub_successful_signon_user_request(permissions: %w[user_update_permission])

      user = User.create!(
        uid: SecureRandom.uuid,
        email: "user@example.com",
        name: "Example User",
        permissions: [],
      )

      expect {
        post "/auth/gds/api/users/#{user.uid}/reauth",
             headers: { "Authorization" => "Bearer anything" }
      }.to change { user.reload.remotely_signed_out }.to(true)

      expect(response).to have_http_status(:success)
      expect(response.body).to eq("")
    end

    it "responds successfully even if the user doesn't exist" do
      stub_successful_signon_user_request(permissions: %w[user_update_permission])

      user = User.new(
        uid: SecureRandom.uuid,
        email: "user@example.com",
        name: "Example User",
        permissions: [],
      )

      post "/auth/gds/api/users/#{user.uid}/reauth",
           headers: { "Authorization" => "Bearer anything" }

      expect(response).to have_http_status(:success)
      expect(response.body).to eq("")
    end
  end

  def user_update_params(user, modifications = {})
    fields = %i[uid name email permissions organisation_slug organisation_content_id disabled]
    user_details = user.as_json(only: fields).merge(modifications)
    { "user" => user_details }
  end
end
