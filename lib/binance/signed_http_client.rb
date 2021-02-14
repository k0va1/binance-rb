# frozen_string_literal: true

require "faraday"
require "json"
require "uri"
require_relative "signer"

module Binance
  class SignedHttpClient < HttpClient
    attr_reader :signer

    def initialize(configuration, prefix)
      super
    end

    def connection
      raise 'add api keys' if configuration.api_key.nil? || configuration.secret_key.nil?
      return @connection if defined?(@connection)

      super
      @connection.use SignRequestMiddleware
      @connection.headers = authenticated_headers
      @connection
    end

    private

    class SignRequestMiddleware < Faraday::Middleware
      def intialize(app)
        @signer = Signer.new(configuration)
        super(app)
      end

      def call(env)
        binding.pry
        env.url.query = env.url.query #todo: sign params
        @app.call(env)
      end

      private

      def signed_params(params)
        encoded_params = URI.encode_www_form(params.to_h)
        params.to_h.merge(signature: @signer.call(encoded_params))
      end
    end

    def authenticated_headers
      {
        "X-MBX-APIKEY" => configuration.api_key
      }
    end

  end
end
