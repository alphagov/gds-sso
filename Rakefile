require 'bundler'
Bundler::GemHelper.install_tasks

load File.dirname(__FILE__) + "/spec/tasks/signonotron_tasks.rake"

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

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

task :default => [:test, :spec]
