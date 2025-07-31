module RequestHelpers
  def authenticate_with_stub_signon(permissions: [])
    state = request_to_establish_oauth_state

    stub_signon_oauth_token_request
    stub_successful_signon_user_request(permissions:)

    get "/auth/gds/callback?code=code&state=#{state}"
    expect(response).to have_http_status(:redirect)
  end

  def request_to_establish_oauth_state
    get "/auth/gds"
    expect(response).to have_http_status(:redirect)
    location = URI.parse(response.location)
    query = Rack::Utils.parse_query(location.query)
    query.fetch("state")
  end

  def stub_signon_oauth_token_request
    stub_request(:post, "http://signon/oauth/access_token")
      .to_return(body: { access_token: "token" }.to_json,
                 headers: { content_type: "application/json" })
  end

  def stub_successful_signon_user_request(permissions: [])
    stub_request(:get, "http://signon/user.json?client_id=gds-sso-test")
      .to_return(
        body: {
          user: {
            uid: "123",
            email: "test-user@example.com",
            name: "Test User",
            permissions:,
          },
        }.to_json,
        headers: { content_type: "application/json" },
      )
  end

  def stub_failed_signon_user_request
    stub_request(:get, "http://signon/user.json?client_id=gds-sso-test")
      .to_return(status: 401)
  end
end
