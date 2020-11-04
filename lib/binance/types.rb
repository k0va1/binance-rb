require 'dry-schema'

module Binance
  module Types
    include Dry.Types()

    Symbol = String.constrained(format: /^[A-Z0-9-_.]{1,20}$/)
    Side = Types::String.enum("BUY", "SELL")
    DepthLimit = Types::Integer.default(100).enum(5, 10, 20, 50, 100, 500, 1000, 5000)
    Limit = Types::Integer.default(500).constrained(gt: 0, lteq: 1000)
    KlineInterval = Types::String.enum("1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M")
    Timestamp = Types::Integer.default { Time.now.to_i * 1000 }.constrained(gt: 0) # in millis

    #This sets how long an order will be active before expiration.
    #Status	Description
    #GTC	Good Til Canceled
    #An order will be on the book unless the order is canceled.
    #IOC	Immediate Or Cancel
    #An order will try to fill the order as much as it can before the order expires.
    #FOK	Fill or Kill
    #An order will expire if the full order cannot be filled upon execution.
    TimeInForce = Types::String.enum("GTC", "IOC", "FOK")

    OrderResponse = Types::String.enum("ACK", "RESULT", "FULL")
    OrderType = Types::String.enum(
      "LIMIT",
      "MARKET",
      "STOP_LOSS",
      "STOP_LOSS_LIMIT",
      "TAKE_PROFIT",
      "TAKE_PROFIT_LIMIT",
      "LIMIT_MAKER"
    )
  end
end
