# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'gds-sso/version'

Gem::Specification.new do |s|
  s.name        = "gds-sso"
  s.version     = GDS::SSO::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Patterson", "James Stewart"]
  s.email       = ["matt@constituentparts.com", "james.stewart@digital.cabinet-office.gov.uk"]
  s.homepage    = "https://github.com/alphagov/gds-sso"
  s.summary     = %q{Client for GDS' OAuth 2-based SSO}
  s.description = %q{Client for GDS' OAuth 2-based SSO}

  s.rubyforge_project = "gds-sso"

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

  s.add_dependency 'rails', '>= 3.0.0'
  s.add_dependency 'warden', '~> 1.2'
  s.add_dependency 'omniauth-gds', '>= 1.0.0'
  s.add_dependency 'rack-accept', '~> 0.4.4'

  s.add_development_dependency 'rake',  '0.9.2.2'
  s.add_development_dependency 'mocha', '0.13.3'
  s.add_development_dependency 'capybara', '1.1.2'
  s.add_development_dependency 'selenium-webdriver', '2.35.1' # Added to resolve dependency resolution fail
  s.add_development_dependency 'rspec-rails', '2.12.2'
  s.add_development_dependency 'capybara-mechanize', '0.3.0'
  s.add_development_dependency 'combustion', '0.3.2'
  s.add_development_dependency 'gem_publisher', '1.0.0'
  s.add_development_dependency 'thor', '0.14.6'
  s.add_development_dependency 'sqlite3', '1.3.6'
  s.add_development_dependency 'timecop', '0.3.5'
end
