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
  s.test_files    = Dir['test/**/*']
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 3.0.0'
  s.add_dependency 'warden', '1.0.6'
  s.add_dependency 'oauth2', '0.4.1'
  s.add_dependency 'oa-oauth', '0.2.6'
  s.add_dependency 'oa-core', '0.2.6'
  s.add_dependency 'rack-accept', '~> 0.4.4'

  s.add_development_dependency 'rake',  '~> 0.9.2'
  s.add_development_dependency 'mocha', '~> 0.9.0'
  s.add_development_dependency 'capybara'
end
