# frozen_string_literal: true

module Binance
  class Futures
    class Client < ::Binance::Client
     def prefix
       "fapi/v1"
     end
    end
  end
end
