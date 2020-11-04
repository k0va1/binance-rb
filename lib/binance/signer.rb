# frozen_string_literal: true

require "openssl"

module Binance
  module Api
    class Signer
      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def call(data)
        raise "You need to provide secret_key to sign the request" unless configuration.secret_key

        OpenSSL::HMAC.hexdigest("SHA256", configuration.secret_key, data)
      end
    end
  end
end
