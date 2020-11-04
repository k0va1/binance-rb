# frozen_string_literal: true

require "faraday"
require "json"
require "uri"

module Binance
  class SignedHttpClient < HttpClient
    attr_reader :signer

    def initialize(configuration, prefix)
      super
      @signer = Signer.new(configuration)
    end

    def connection
      raise 'add api keys' if configuration.api_key.nil? || configuration.secret_key.nil?

      super
      connection.use SignRequestMiddleware
      conneciton.headers = authenticated_headers
    end

    private

    class SignRequestMiddleware < Faraday::Middleware
      def intialize(app)
        super(app)
      end

      def call(env)
        env.url.query = env.url.query #todo: sign params
        @app.call(env)
      end
    end

    def authenticated_headers
      {
        "X-MBX-APIKEY" => configuration.api_key
      }
    end

    def signed_params(params)
      encoded_params = URI.encode_www_form(params.to_h)
      params.to_h.merge(signature: signer.call(encoded_params))
    end
  end
end
