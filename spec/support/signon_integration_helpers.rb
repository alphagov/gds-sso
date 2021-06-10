require "net/http"

module SignonIntegrationHelpers
  def wait_for_signon_to_start
    retries = 0
    url = GDS::SSO::Config.oauth_root_url
    puts "Waiting for signon to start at #{url}"
    until signon_started?(url)
      print "."
      if retries > 20
        raise "Signon is not running at #{url}. Please start with `./start_signon.sh`. Under jenkins this should happen automatically."
      end

      retries += 1
      sleep 1
    end
    puts "Signon is now running at #{url}"
  end

  def signon_started?(url)
    uri = URI.parse(url)
    conn = Net::HTTP.start(uri.host, uri.port)
    true
  rescue Errno::ECONNREFUSED
    false
  ensure
    conn.try(:finish)
  end

  def load_signon_setup_fixture
    load_signon_fixture("signon.sql")
  end

  def authorize_signon_api_user
    load_signon_fixture("authorize_api_users.sql")
  end

  def load_signon_fixture(filename)
    require "erb"
    parsed = ERB.new(File.read("#{signon_path}/config/database.yml")).result
    db = YAML.safe_load(parsed, aliases: true)["test"]

    cmd = "mysql #{db['database']} -u#{db['username']} -p#{db['password']} < #{fixture_file(filename)}"
    system cmd or raise "Error loading signon fixture"
  end

private

  def fixture_file(filename)
    File.join(File.dirname(__FILE__), "../fixtures/integration", filename)
  end

  def signon_path
    Rails.root.join("..", "..", "tmp", "signon").to_s
  end
end
