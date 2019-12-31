# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'gds-sso/version'

Gem::Specification.new do |s|
  s.name        = "gds-sso"
  s.version     = GDS::SSO::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["GOV.UK Dev"]
  s.email       = ["govuk-dev@digital.cabinet-office.gov.uk"]
  s.homepage    = "https://github.com/alphagov/gds-sso"
  s.summary     = %q{Client for GDS' OAuth 2-based SSO}
  s.description = %q{Client for GDS' OAuth 2-based SSO}
  s.license     = 'MIT'

  s.required_ruby_version = ">= 2.2.2"

  s.files         = Dir[
    'app/**/*',
    'config/**/*',
    'lib/**/*',
    'README.md',
    'Gemfile',
    'Rakefile'
  ]
  s.test_files    = Dir['test/**/*', 'spec/**/*']
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 4'
  s.add_dependency 'warden', '~> 1.2'
  s.add_dependency 'oauth2', '~> 1.0'
  s.add_dependency 'omniauth', '~> 1.2'
  s.add_dependency 'omniauth-gds', '~> 3.2'
  s.add_dependency 'warden-oauth2', '~> 0.0.1'
  s.add_dependency 'multi_json', '~> 1.0'

  s.add_development_dependency 'rake',  '>= 0.9'
  s.add_development_dependency 'capybara', '>= 2'
  s.add_development_dependency 'rspec-rails', '>= 3'
  s.add_development_dependency 'capybara-mechanize', '>= 1'
  s.add_development_dependency 'combustion', '>= 0.9'
  s.add_development_dependency 'sqlite3', '~> 1.4.2'
  s.add_development_dependency 'timecop', '>= 0.3'

  # Additional development dependencies added to Gemfile to aid dependency resolution.
end
