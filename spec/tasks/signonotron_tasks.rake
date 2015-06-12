namespace :signonotron do
  desc "Start signonotron (for integration tests)"
  task :start => :stop do

    @app_to_launch = "signonotron2"

    puts "Launching: #{@app_to_launch}"

    gem_root = Pathname.new(File.dirname(__FILE__)) + '..' + '..'
    FileUtils.mkdir_p(gem_root + 'tmp')
    Dir.chdir gem_root + 'tmp' do
      if File.exist? @app_to_launch
        Dir.chdir @app_to_launch do
          puts `git clean -fdx`
          puts `git fetch origin`
          puts `git reset --hard origin/master`
        end
      else
        puts `git clone git@github.com:alphagov/#{@app_to_launch}`
      end

      if signon_commitish = ENV['SIGNON_COMMITISH']
        puts "Checking out non-master of signon: #{signon_commitish}"
        Dir.chdir(@app_to_launch) do
          system `git checkout #{signon_commitish}` || raise("Unable to checkout #{signon_commitish}")
        end
      end
    end

    Dir.chdir gem_root + 'tmp' + @app_to_launch do
      env_to_clear = %w(BUNDLE_GEMFILE BUNDLE_BIN_PATH RUBYOPT GEM_HOME GEM_PATH RBENV_VERSION)

      env_stuff = case `uname`.strip
      when "Darwin"
        env_to_clear.map { |e| "unset #{e}" }.join(" && ") + " && "
      else
        "/usr/bin/env " + env_to_clear.map { |e| "-u #{e}" }.join(" ")
      end
      env_stuff += " RAILS_ENV=test"
      if ENV.has_key?('ORIGINAL_PATH')
        env_stuff += " PATH=#{ENV.fetch('ORIGINAL_PATH')}"
      end

      puts "Running bundler"
      puts `#{env_stuff} bundle install --path=#{gem_root + 'tmp' + "#{@app_to_launch}_bundle"}`
      puts `#{env_stuff} bundle exec rake db:drop db:create db:schema:load`

      puts "Starting signonotron instance in the background"
      fork do
        Process.daemon(true)
        exec "#{env_stuff} bundle exec rails s -p 4567"
      end
    end
  end

  desc "Stop running signonotron (for integration tests)"
  task :stop do
    pid_output = `lsof -Fp -i :4567`.chomp
    if pid_output =~ /\Ap(\d+)\z/
      puts "Stopping running instance of Signonotron (pid #{$1})"
      Process.kill(:INT, $1.to_i)
    end
  end
end

