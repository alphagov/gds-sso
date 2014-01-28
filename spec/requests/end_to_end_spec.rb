require 'spec_helper'
require 'timecop'

describe "Integration of client using GDS-SSO with signonotron" do
  include Signonotron2IntegrationHelpers

  before :all do
    wait_for_signonotron_to_start
  end

  before :each do
    @client_host = 'www.example-client.com'
    Capybara.current_driver = :mechanize
    Capybara::Mechanize.local_hosts << @client_host

    load_signonotron_setup_fixture
  end

  describe "Web client accesses" do
    before :each do
      page.driver.header 'accept', 'text/html'
    end

    specify "a non-restricted page can be accessed without authentication" do
      visit "http://#{@client_host}/"
      page.should have_content('jabberwocky')
    end

    specify "first access to a restricted page requires authentication and application approval" do
      visit "http://#{@client_host}/restricted"
      page.should have_content("Sign in")
      fill_in "Email", :with => "test@example-client.com"
      fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
      click_on "Sign in"

      page.should have_content('restricted kablooie')
    end

    specify "access to a restricted page for an approved application requires only authentication" do
      # First we login to authorise the app
      visit "http://#{@client_host}/restricted"
      fill_in "Email", :with => "test@example-client.com"
      fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
      click_on "Sign in"

      # At this point the app should be authorised, we reset the session to simulate a new browser visit.
      reset_session!
      page.driver.header 'accept', 'text/html'

      visit "http://#{@client_host}/restricted"
      page.should have_content("Sign in")
      fill_in "Email", :with => "test@example-client.com"
      fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
      click_on "Sign in"

      page.should have_content('restricted kablooie')
    end

    specify "access to a page that requires signin permission granted" do
      # First we login to authorise the app
      visit "http://#{@client_host}/this_requires_signin_permission"
      fill_in "Email", :with => "test@example-client.com"
      fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
      click_on "Sign in"

      # At this point the app should be authorised, we reset the session to simulate a new browser visit.
      reset_session!
      page.driver.header 'accept', 'text/html'

      visit "http://#{@client_host}/this_requires_signin_permission"
      page.should have_content("Sign in")
      fill_in "Email", :with => "test@example-client.com"
      fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
      click_on "Sign in"

      page.should have_content('you have signin permission')
    end

    describe "remotely signed out" do
      specify "should prevent all access to the application until successful signin" do
        # First we login and authorise the app
        visit "http://#{@client_host}/restricted"
        fill_in "Email", :with => "test@example-client.com"
        fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
        click_on "Sign in"

        page.driver.header 'accept', 'text/html'
        page.should have_content('restricted kablooie')

        # logout from signon
        visit "http://localhost:4567/users/sign_out"

        # Simulate a POST to /auth/gds/api/users/:uid/reauth by signon
        # This is already tested in api_user_controller_spec.rb
        user = User.where(:email => "test@example-client.com").first
        user.set_remotely_signed_out!

        # attempt to visit a restricted page
        visit "http://#{@client_host}/restricted"

        # be redirected to signon
        page.should have_content('GOV.UK Signon')
        fill_in "Email", :with => "test@example-client.com"
        fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
        click_on "Sign in"

        # then back again to the restricted page
        page.should have_content('restricted kablooie')
      end
    end

    describe "session expiry" do
      it "should force you to re-authenticate with signonotron N hours after login" do
        visit "http://#{@client_host}/restricted"
        page.should have_content("Sign in")
        fill_in "Email", :with => "test@example-client.com"
        fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
        click_on "Sign in"

        page.should have_content('restricted kablooie')

        Timecop.travel(Time.now.utc + GDS::SSO::Config.auth_valid_for + 5.minutes) do
          visit "http://#{@client_host}/restricted"
        end

        page.driver.request.referrer.should =~ %r(\Ahttp://#{@client_host}/auth/gds/callback)
      end


      it "should not require re-authentication with signonotron fewer than N hours after login" do
        visit "http://#{@client_host}/restricted"
        page.should have_content("Sign in")
        fill_in "Email", :with => "test@example-client.com"
        fill_in "Passphrase", :with => "q1w2e3r4t5y6u7i8o9p0"
        click_on "Sign in"

        page.should have_content('restricted kablooie')

        Timecop.travel(Time.now.utc + GDS::SSO::Config.auth_valid_for - 5.minutes) do
          visit "http://#{@client_host}/restricted"
        end

        page.driver.request.referrer.should =~ %r(\Ahttp://#{@client_host}/restricted)
      end
    end
  end

  describe "OAuth based API client accesses" do
    before :each do
      page.driver.header 'accept', 'application/json'
      authorize_signonotron_api_user

      token = "caaeb53be5c7277fb0ef158181bfd1537b57f9e3b83eb795be3cd0af6e118b28"
      page.driver.header 'authorization', "Bearer #{token}"
    end

    specify "access to a restricted page for an api client requires auth" do
      page.driver.header 'authorization', 'Bearer Bad Token'
      visit "http://#{@client_host}/restricted"
      page.driver.response.status.should == 401
    end

    specify "setting a correct bearer token allows sign in" do
      visit "http://#{@client_host}/restricted"
      page.should have_content('restricted kablooie')
    end

    specify "setting a correct bearer token picks up permissions" do
      visit "http://#{@client_host}/this_requires_signin_permission"
      page.should have_content('you have signin permission')
    end
  end
end
