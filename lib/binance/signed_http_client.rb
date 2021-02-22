# frozen_string_literal: true

require "faraday"
require "json"
require "uri"
require_relative "signer"

module Binance
  class SignedHttpClient < HttpClient
    def connection
      raise 'add api keys' if configuration.api_key.nil? || configuration.secret_key.nil?
      return @connection if defined?(@connection)

      super

      @connection.use SignRequestMiddleware, configuration
      @connection.headers = authenticated_headers
      @connection
    end

    private

    class SignRequestMiddleware < Faraday::Middleware
      def initialize(app=nil, configuration=nil)
        @signer = Signer.new(configuration)
        super(app)
      end

      def call(env)
        env.url.query = sign_params(env.url.query)
        @app.call(env)
      end

      private

      def sign_params(query_string)
        query_string.to_s + "&signature=#{@signer.call(query_string.to_s)}"
      end
    end

    def authenticated_headers
      {
        "X-MBX-APIKEY" => configuration.api_key
      }
    end
  end
end
