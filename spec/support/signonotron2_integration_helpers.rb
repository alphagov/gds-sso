require 'net/http'

module Signonotron2IntegrationHelpers
  def wait_for_signonotron_to_start
    retries = 0
    url = GDS::SSO::Config.oauth_root_url
    puts "Waiting for signonotron to start at #{url}"
    while ! signonotron_started?(url)
      print '.'
      if retries > 10
        raise "Signonotron is not running at #{url}. Please start with 'bundle exec rake signonotron:start'. Under jenkins this should have been run automatically"
      end
      retries += 1
      sleep 1
    end
    puts "Signonotron is now running at #{url}"
  end

  def signonotron_started?(url)
    uri = URI.parse(url)
    conn = Net::HTTP.start(uri.host, uri.port)
    true
  rescue Errno::ECONNREFUSED
    false
  ensure
    conn.try(:finish)
  end

  def load_signonotron_fixture
    fixtures_path = Pathname.new(File.join(File.dirname(__FILE__), '../fixtures/integration'))
    db = YAML.load_file(fixtures_path + 'signonotron2_database.yml')['test']
    cmd = "mysql -u#{db['username']} -p#{db['password']} #{db['database']} < #{fixtures_path + 'signonotron2.sql'}"
    system cmd or raise "Error loading signonotron fixture"
  end
end
