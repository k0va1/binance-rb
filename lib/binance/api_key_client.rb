# frozen_string_literal: true

require "faraday"

module Binance
  class ApiKeyClient < HttpClient
    def connection
      return @connection if defined?(@connection)

      super
      @connection.headers = authenticated_headers
      @connection
    end

    private

    def authenticated_headers
      {
        "X-MBX-APIKEY" => configuration.api_key
      }
    end
  end
end
