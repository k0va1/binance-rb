module Binance
  class Margin
    class Client < ::Binance::Client
      def prefix
        "sapi/v1/margin"
      end
    end
  end
end
