module Binance
  class Withdrawal
    class Client < ::Binance::Client
      def prefix
        "wapi/v3"
      end
    end
  end
end
