require_relative '../spec_helper'

include Rack::Test

describe "authenticating with sign-on-o-tron" do

  describe "when not signed in" do

    describe "a protected page" do
      it "redirects to /auth/gds" do
        get "/restricted"

        response.code.should == "302"
        response.location.should == "http://www.example.com/auth/gds"
      end
    end

    describe "/auth/gds" do
      it "redirects to signonotron2" do
        get "/auth/gds"

        response.code.should == "302"
        response.location.should =~ /^http:\/\/localhost:4567\/oauth\/authorize/
      end

      it "authenticates with a username and password and redirects back to the app" do
        get "/auth/gds"

        uri = URI.parse(response.location)
        auth_path = uri.path + '?' + uri.query

        client_cookies = response.headers['Set-Cookie'].split('; ')[0]

        @signonotron = Faraday.new(:url => "#{uri.scheme}://#{uri.host}:#{uri.port}") do |builder|
          builder.request :url_encoded
          builder.adapter :net_http
        end

        authz_return_location = do_auth_request(auth_path)

        return_path = authz_return_location.path + '?' + (authz_return_location.query || '')

        get return_path, { }, { 'Cookie' => client_cookies }

        puts "HANDLE AUTH RESULT\n====================\n"
        puts response.headers

        # resp = Net::HTTP.get_response( URI::parse(response.location) )
        # location = resp["location"]

        # visit location
        # puts page.current_uri

        # fill_in "user_email", :with => "foo@example.com"
        # fill_in "user_password", :with => "this is an example for the test"
        # click_button "Sign in"
      end

      def do_auth_request(auth_path)
        auth_request = @signonotron.get(auth_path)

        debug_request('Auth Request', 'GET', auth_path, auth_request, '')

        sign_in_location = URI.parse(auth_request.headers['location']).path
        cookie = auth_request.headers['Set-Cookie'].split('; ')[0]

        return do_sign_in_request(sign_in_location, cookie)
      end

      def do_sign_in_request(sign_in_location, cookie)
        sign_in_request = @signonotron.get do |req|
          req.url sign_in_location
          req.headers['Cookie'] = cookie
        end

        debug_request('Sign In', 'GET', sign_in_location, sign_in_request, cookie)

        cookie = sign_in_request.headers['Set-Cookie'].split('; ')[0]
        sign_in_location =  Nokogiri.parse(sign_in_request.body).xpath("//form").first.attributes['action'].text
        authenticity_token = Nokogiri.parse(sign_in_request.body).xpath("//input[@name='authenticity_token']").first.attributes['value'].text

        return do_sign_in_post(sign_in_location, cookie, authenticity_token)
      end

      def do_sign_in_post(sign_in_location, cookie, authenticity_token)

        sign_in_post = @signonotron.post do |req|
          req.url sign_in_location
          req.body = { :user => { :email => 'foo@example.com', :password => 'this is an example for the test' }, :authenticity_token => authenticity_token }
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.headers['Cookie'] = cookie
        end

        debug_request('Sign In', 'POST', sign_in_location, sign_in_post, cookie)

        cookie = sign_in_post.headers['Set-Cookie'].split('; ')[0]
        authz_location = URI.parse(sign_in_post.headers['location'])

        return authz_location
      end

      def debug_request(name, method, path, response, cookie)
        puts "#{name} REQUEST RESULT:\n=========================\n"
        puts "#{method} #{path}"
        puts "#{cookie}"

        puts "\n\n"

        puts response.headers.inspect
        puts response.body
      end
    end

  end

end
