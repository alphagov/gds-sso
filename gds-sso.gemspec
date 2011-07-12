# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "gds-sso"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Patterson"]
  s.email       = ["matt@alphagov.co.uk"]
  s.homepage    = ""
  s.summary     = %q{Client for GDS' OAuth 2-based SSO}
  s.description = %q{Client for GDS' OAuth 2-based SSO}

  s.rubyforge_project = "gds-sso"

  s.files         = Dir[
    'lib/**/*',
    'README.md',
    'Gemfile',
    'Rakefile'
  ]
  s.test_files    = Dir['test/**/*']
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 3.0.0'
  s.add_dependency 'warden'
  s.add_dependency 'oa-oauth'

  s.add_development_dependency 'rake',  '~> 0.9.2'
  s.add_development_dependency 'mocha', '~> 0.9.0'
end
