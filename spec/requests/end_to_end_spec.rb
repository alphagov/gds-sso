require 'spec_helper'

describe "Integration of client using GDS-SSO with signonotron" do
  include Signonotron2IntegrationHelpers

  before :all do
    wait_for_signonotron_to_start
  end

  before :each do
    @client_host = 'www.example-client.com'
    Capybara.current_driver = :mechanize
    Capybara::Mechanize.local_hosts << @client_host
    page.driver.header 'accept', 'text/html'

    load_signonotron_fixture
  end

  specify "accessing a restricted page, and logging in successfully" do
    visit "http://#{@client_host}/"
    page.should have_content("Sign in")
    fill_in "Email", :with => "test@example-client.com"
    fill_in "Password", :with => "q1w2e3r4t5y6u7i8o9p0"
    click_on "Sign in"

    click_on "Authorize"

    page.should have_content('jabberwocky')
  end
end
