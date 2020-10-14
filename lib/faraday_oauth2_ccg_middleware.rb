# frozen_string_literal: true

require 'faraday_oauth2_ccg_middleware/version'
require 'faraday'
require 'json'

module FaradayOauth2CcgMiddleware

  class Error < StandardError; end

  # Authorizes the request with the OAUTH2 Client Credentials Grant and injects the received token
  # into the Authorization header
  #
  # @example Configure OAUTH Client Credentials Grant middleware
  # Faraday.new do |conn|
  #   conn.request :oauth2_ccg,
  #                oauth_host:    'https://server.example.com',
  #                token_url:     '/token',
  #                client_id:     's6BhdRkqt3',
  #                client_secret: '7Fjfp0ZBr1KtDRbnfVdmIw',
  #                cache_store:   ::ActiveSupport::Cache.lookup_store(:redis_store, 'redis://127.0.0.1:6379')
  #
  #   conn.adapter(:net_http) # NB: Last middleware must be the adapter
  # end
  class ClientCredentialsGrant < Faraday::Middleware
    class Options < Faraday::Options.new(:oauth_host, :token_url,
                                         :client_id, :client_secret,
                                         :cache_store)

      def self.from(value)
        super(value)
      end

      def oauth_host
        self[:oauth_host] ||= ''
      end

      def token_url
        self[:token_url] ||= ''
      end

      def client_id
        self[:client_id] ||= ''
      end

      def client_secret
        self[:client_secret] ||= ''
      end

      def cache_store
        self[:cache_store] ||= nil
      end
    end

    AUTHORIZATION_HEADER = 'Authorization'
    BEARER_AUTHORIZATION = 'Bearer'
    CLIENT_CREDENTIALS_GRANT = 'client_credentials'

    # @param app [#call]
    # @param options [Hash]
    # @option options [String] :oauth_host ('') OAUTH2 server host
    # @option options [String] :token_url ('') Token endpoint to request authorization
    # @option options [String] :client_id ('') Client authentication id
    # @option options [String] :client_secret ('') Client authentication password
    # @option options [Class] :cache_store (nil) An ActiveSupport::Cache::Store instance for token caching
    def initialize(app, options = nil)
      super(app)
      @options = Options.from(options)
    end

    # @param env [Faraday::Env]
    def call(env)
      env[:request_headers][AUTHORIZATION_HEADER] = "#{BEARER_AUTHORIZATION} #{token}"

      @app.call env
    end

    private

    def token
      if @options.cache_store
        return @options.cache_store.fetch(cache_key, expires_in: token_object['expires_in']) do
          token_object['access_token']
        end
      end

      token_object['access_token']
    end

    def token_object
      @token_object ||= JSON.parse(oauth_response.body)
    end

    def oauth_response
      @oauth_response ||= auth_conn.post(
        @options.token_url,
        grant_type:    CLIENT_CREDENTIALS_GRANT,
        client_id:     @options.client_id,
        client_secret: @options.client_secret
      )
    end

    def auth_conn
      Faraday.new(url: @options.oauth_host)
    end

    def cache_key
      Digest::MD5.hexdigest("#{@options.oauth_host}#{@options.client_id}#{@options.client_secret}")
    end
  end

  Faraday::Request.register_middleware oauth2_ccg: FaradayOauth2CcgMiddleware::ClientCredentialsGrant
end
