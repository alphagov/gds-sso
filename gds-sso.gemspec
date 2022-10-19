lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require "gds-sso/version"

Gem::Specification.new do |s|
  s.name        = "gds-sso"
  s.version     = GDS::SSO::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["GOV.UK Dev"]
  s.email       = ["govuk-dev@digital.cabinet-office.gov.uk"]
  s.homepage    = "https://github.com/alphagov/gds-sso"
  s.summary     = "Client for GDS' OAuth 2-based SSO"
  s.description = "Client for GDS' OAuth 2-based SSO"
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.7"

  s.files = Dir[
    "app/**/*",
    "config/**/*",
    "lib/**/*",
    "README.md",
    "Gemfile",
    "Rakefile"
  ]
  s.test_files    = Dir["test/**/*", "spec/**/*"]
  s.executables   = []
  s.require_paths = %w[lib]

  s.add_dependency "multi_json", "~> 1.0"
  s.add_dependency "oauth2", ">= 1", "< 3"
  s.add_dependency "omniauth", ">= 1.2", "< 3.0"
  s.add_dependency "omniauth-gds", "~> 3.2"
  s.add_dependency "plek", "~> 4.0"
  s.add_dependency "rails", ">= 5"
  s.add_dependency "warden", "~> 1.2"
  s.add_dependency "warden-oauth2", "~> 0.0.1"

  s.add_development_dependency "capybara", "~> 3"
  s.add_development_dependency "capybara-mechanize", "~> 1", ">= 1.12.1" # Require at least 1.12.1 because of compatibility issue with Capybara 3.37.0
  s.add_development_dependency "combustion", ">= 0.9"
  s.add_development_dependency "net-smtp", "~> 0.3.1"
  s.add_development_dependency "rake", ">= 0.9"
  s.add_development_dependency "rspec-rails", ">= 3"
  s.add_development_dependency "rubocop-govuk"
  s.add_development_dependency "sqlite3", "~> 1.4"
  s.add_development_dependency "timecop", ">= 0.3"

  # Additional development dependencies added to Gemfile to aid dependency resolution.
end
