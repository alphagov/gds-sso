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

  s.add_dependency "oauth2", "~> 2.0"
  s.add_dependency "omniauth", "~> 2.1"
  s.add_dependency "omniauth-oauth2", "~> 1.8"
  s.add_dependency "plek", ">= 4", "< 6"
  s.add_dependency "rails", ">= 6"
  s.add_dependency "warden", "~> 1.2"
  s.add_dependency "warden-oauth2", "~> 0.0.1"

  s.add_development_dependency "byebug"
  s.add_development_dependency "capybara", "~> 3"
  s.add_development_dependency "combustion", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-rails", "~> 6"
  s.add_development_dependency "rubocop-govuk", "4.9.0"
  s.add_development_dependency "sqlite3", "~> 1.5"
  s.add_development_dependency "timecop", "~> 0.9"
  s.add_development_dependency "webmock"
end
