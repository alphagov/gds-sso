require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

task :default => :test

namespace :signonotron do
  desc "Start signonotron (for integration tests)"
  task :start do
    gem_root = Pathname.new(File.dirname(__FILE__))
    FileUtils.mkdir_p(gem_root + 'tmp')
    Dir.chdir gem_root + 'tmp'
    if File.exist? "signonotron2"
      Dir.chdir "signonotron2"
      puts `git clean -fdx`
      puts `git fetch origin`
      puts `git reset --hard origin/master`
    else
      puts `git clone git@github.com:alphagov/signonotron2`
      Dir.chdir "signonotron2"
    end
    env_stuff = '/usr/bin/env -u BUNDLE_GEMFILE -u BUNDLE_BIN_PATH -u RUBYOPT'
    ENV['RAILS_ENV'] = 'test'
    puts `#{env_stuff} bundle install --path=#{gem_root + 'tmp' + 'signonotron2_bundle'}`
    FileUtils.cp gem_root.join('spec', 'fixtures', 'integration', 'so2_database.yml'), File.join('config', 'database.yml')
    puts `#{env_stuff} bundle exec rake db:drop db:create db:schema:load`

    puts "Starting signonotron instance in the background"
    fork do
      Process.daemon(true)
      exec "#{env_stuff} bundle exec rails s -p 4567"
    end
  end

  desc "Stop running signonotron (for integration tests)"
  task :stop do
    so2_pid_file = Pathname.new(File.dirname(__FILE__)) + 'tmp' + 'signonotron2' + 'tmp' + 'pids' + 'server.pid'
    if File.exist?(so2_pid_file)
      pid = File.read(so2_pid_file).chomp.to_i
      Process.kill(:INT, pid)
    end
  end
end
