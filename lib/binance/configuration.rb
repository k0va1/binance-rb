# frozen_string_literal: true

module Binance
  class Configuration
    attr_accessor :api_key, :secret_key

    def initialize(api_key, secret_key)
      @api_key = api_key
      @secret_key = secret_key
    end

    def has_credentials?
      api_key && secret_key
    end
  end
end
