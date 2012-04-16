require 'spec_helper'

describe "End to end test" do
  before :each do
    @client_host = 'www.example-client.com'
    @signon_host = 'signonotron.dev.gov.uk'
    Capybara.current_driver = :mechanize
    Capybara::Mechanize.local_hosts << @client_host
    page.driver.header 'accept', 'text/html'
  end

  specify "accessing a restricted page, and logging in successfully" do
    visit "http://#{@client_host}/"
    page.should have_content("Sign in")
    fill_in "Email", :with => "test@example-client.com"
    fill_in "Password", :with => "q1w2e3r4t5y6u7i8o9p0"
    click_on "Sign in"
    page.should have_content('jabberwocky')
  end
end
