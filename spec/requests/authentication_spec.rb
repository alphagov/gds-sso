require_relative '../spec_helper'

include Rack::Test

describe "authenticating with sign-on-o-tron" do

  describe "when not signed in" do

    describe "a protected page" do
      it "redirects to /auth/gds" do
        get "/"

        response.code.should == "302"
        response.location.should == "http://www.example.com/auth/gds"
      end
    end

    describe "/auth/gds" do
      it "redirects to sign-on-o-tron" do
        get "/auth/gds"

        response.code.should == "302"
        response.location.should =~ /http:\/\/localhost:4567\/oauth\/authorize/
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

        auth_request, sign_in_location, cookie =    do_auth_request(auth_path)
        sign_in_request, sign_in_location, cookie = do_sign_in_request(sign_in_location, cookie)

        authenticity_token = Nokogiri.parse(sign_in_request.body).xpath("//input[@name='authenticity_token']").first.attributes['value'].text
        sign_in_post, authz_location, cookie =      do_sign_in_post(sign_in_location, cookie, authenticity_token)

        authz_request, authz_return_location, authz_confirm_location, cookie = do_authz_request(authz_location, cookie)

        if authz_confirm_location
          puts "confirming auth request"
          authenticity_token = Nokogiri.parse(authz_request.body).xpath("//input[@name='authenticity_token']").first.attributes['value'].text
          authz_confirm_request, authz_return_location, cookie = do_authz_confirm_post(authz_confirm_location, cookie, authenticity_token)
        end

        # client = Faraday.new(:url => "#{return_uri.scheme}://#{return_uri.host}:#{return_uri.port}") do |builder|
        #   builder.request :url_encoded
        #   builder.adapter :net_http
        # end

        # puts "AUTH REQUEST RESULT:\n=========================\n"
        # puts "GET #{post_path}\n\n"
        # puts authz_request.headers.inspect
        # puts authz_request.body
        # puts authz_request.headers['location']
        # puts client_cookies.inspect

        return_path = authz_return_location.path + '?' + authz_return_location.query

        puts return_uri

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

        sign_in_location = URI.parse(auth_request.headers['location']).path
        cookie = auth_request.headers['Set-Cookie'].split('; ')[0]

        return [auth_request, sign_in_location, cookie]
      end

      def do_sign_in_request(sign_in_location, cookie)
       sign_in_request = @signonotron.get do |req|
         req.url sign_in_location
         req.headers['Cookie'] = cookie
       end

       cookie = sign_in_request.headers['Set-Cookie'].split('; ')[0]
       sign_in_location =  Nokogiri.parse(sign_in_request.body).xpath("//form").first.attributes['action'].text

       return [sign_in_request, sign_in_location ,cookie]
      end

      def do_sign_in_post(sign_in_location, cookie, authenticity_token)

        sign_in_post = @signonotron.post do |req|
          req.url sign_in_location
          req.body = { :user => { :email => 'foo@example.com', :password => 'this is an example for the test' }, :authenticity_token => authenticity_token }
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.headers['Cookie'] = cookie
        end

        cookie = sign_in_post.headers['Set-Cookie'].split('; ')[0]
        authz_location = URI.parse(sign_in_post.headers['location'])


        return [sign_in_post, authz_location, cookie]
      end

      def do_authz_request(authz_location, cookie)
        authz_request = @signonotron.get do |req|
          req.url authz_location.path + "?" + authz_location.query
          req.headers['Content-Type'] = 'text/html'
          req.headers['Cookie'] = cookie
        end

        cookie = authz_request.headers['Set-Cookie'].split('; ')[0]

        if authz_request.headers['location']
          authz_return_location = URI.parse(authz_request.headers['location'])
        else
          authz_confirm_location = Nokogiri.parse(authz_request.body).xpath("//form").first.attributes['action'].text
        end

        return [authz_request, authz_return_location, authz_confirm_location, cookie]
      end

      def do_authz_confirm_post(authz_confirm_location, cookie, authenticity_token)
        authz_confirm_request = @signonotron.post do |req|
          req.url authz_confirm_location
          req.body = { :commit => 'Yes', :auth_token => authenticity_token }
          req.headers['Cookie'] = cookie
        end

        cookie = authz_confirm_request.headers['Set-Cookie'].split('; ')[0]
        authz_return_location = URI.parse(authz_confirm_request.headers['location'])

        puts authz_return_location
        puts authz_confirm_request.headers['location']

        return [authz_confirm_request, authz_return_location, cookie]
      end
    end

  end

end