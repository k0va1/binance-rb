# frozen_string_literal: true

require "faraday"
require "json"
require "uri"

module Binance
  class HttpClient
    BASE_ENDPOINT = "https://api.binance.com"

    attr_reader :connection, :configuration

    def initialize(configuration, prefix)
      @configuration = configuration
      @prefix = prefix
    end

    def connection
      @connection ||= Faraday.new(url: url)
    end

    def get(name, params: {})
      make_request(path: name, type: :get, params: params)
    end

    def post(name, params: {}, body: {})
      make_request(path: name, type: :post, params: params, body: body)
    end

    def put(name, params: {}, body: {})
      make_request(path: name, type: :put, params: params, body: body)
    end

    def delete(name, params: {}, body: {})
      make_request(path: name, type: :delete, params: params, body: body)
    end

    private

    def make_request(path:, type:, params: {}, body: {})
      response = connection.send(type) do |req|
        req.path = path
        req.params = params.to_h
        req.body = body
      end
    end

    def url
      [BASE_ENDPOINT, @prefix].join("/")
    end
  end
end
