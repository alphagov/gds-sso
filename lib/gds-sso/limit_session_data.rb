module GDS
  module SSO
    class LimitSessionData
      MAX_SESSION_DATA_SIZE = 2048
      MANAGED_KEYS = %w[return_to].freeze
      MANAGED_KEY_PREFIXES = %w[omniauth. warden.].freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        session = env["rack.session"]
        return [status, headers, body] unless session.respond_to?(:to_hash)

        if gds_sso_session_bytesize(session) > MAX_SESSION_DATA_SIZE
          logger.warn("[gds-sso] Rejecting request: data added to the session by gds-sso exceeds #{MAX_SESSION_DATA_SIZE} bytes")
          purge_gds_sso_session_data!(session)
          return bad_request
        end

        [status, headers, body]
      end

    private

      def gds_sso_session_bytesize(session)
        session.to_hash.sum do |key, value|
          managed_key?(key) ? key.bytesize + serialized_bytesize(value) : 0
        end
      end

      def serialized_bytesize(value)
        JSON.generate(value).bytesize
      rescue StandardError
        # If we can't serialise it to measure it, assume it's too large
        Float::INFINITY
      end

      def managed_key?(key)
        MANAGED_KEYS.include?(key) || MANAGED_KEY_PREFIXES.any? { |prefix| key.start_with?(prefix) }
      end

      def purge_gds_sso_session_data!(session)
        session.to_hash.each_key do |key|
          session.delete(key) if managed_key?(key)
        end
      end

      def bad_request
        body = "Bad Request"
        [
          400,
          {
            "Content-Type" => "text/plain; charset=utf-8",
            "Content-Length" => body.bytesize.to_s,
            "Cache-Control" => "no-cache",
          },
          [body],
        ]
      end

      def logger
        Rails.logger
      end
    end
  end
end
