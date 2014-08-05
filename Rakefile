require 'bundler/setup'
require 'bundler/gem_tasks'
require 'wwtd/tasks'

Bundler::GemHelper.install_tasks

load File.dirname(__FILE__) + "/spec/tasks/signonotron_tasks.rake"

require 'rspec/core/rake_task'
desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.pattern = 'spec/**/*_spec.rb'
end

namespace :spec do
  desc "Run integration specs"
  RSpec::Core::RakeTask.new(:integration) do |task|
    task.pattern = 'spec/integration/**/*_spec.rb'
  end
end

require "gem_publisher"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("gds-sso.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end

task :default => [:wwtd]
