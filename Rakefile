require 'bundler/setup'
require 'bundler/gem_tasks'

Bundler::GemHelper.install_tasks

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

desc "Lint Ruby"
task :lint do
  sh "bundle exec rubocop --format clang"
end

task default: %i[spec lint]
