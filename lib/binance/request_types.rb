require "dry/validation"
require_relative "types"

module Binance
  DepthParamsSchema = Dry::Validation::Contract.build do
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      required(:limit).filled(Binance::Types::DepthLimit)
    end
  end

  TradesParamsSchema = Dry::Validation::Contract.build do
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      required(:limit).filled(Binance::Types::Limit)
    end
  end

  HistoricalTradesParamsSchema = Dry::Validation::Contract.build do
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      required(:limit).filled(Binance::Types::Limit)
      optional(:from_id).filled(:integer, gt?: 0)
    end
  end

  AggTradesParamsSchema = Dry::Validation::Contract.build do
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      required(:limit).filled(Binance::Types::Limit)
      optional(:from_id).filled(:integer, gt?: 0)
      optional(:start_time).filled(:integer, gt?: 0)
      optional(:end_time).filled(:integer, gt?: 0)
    end
  end

  KlinesParamsSchema = Dry::Validation::Contract.build do
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      required(:limit).filled(Binance::Types::Limit)
      optional(:start_time).filled(:integer, gt?: 0)
      optional(:end_time).filled(:integer, gt?: 0)
      optional(:interval).filled(Binance::Types::KlineInterval)
    end
  end

  AvgPriceParamsSchema = Dry::Validation::Contract.build do
    params do
      required(:symbol).filled(Binance::Types::Symbol)
    end
  end

  PriceChange24ParamsSchema = Dry::Validation::Contract.build do
    params do
      optional(:symbol).filled(Binance::Types::Symbol)
    end
  end

  SymbolPriceParamsSchema = Dry::Validation::Contract.build do
    params do
      optional(:symbol).filled(Binance::Types::Symbol)
    end
  end

  OrderBookTickerParamsSchema = Dry::Validation::Contract.build do
    params do
      optional(:symbol).filled(Binance::Types::Symbol)
    end
  end

  class NewOrderContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      required(:side).filled(Binance::Types::Side)
      required(:type).filled(Binance::Types::OrderType)

      optional(:time_in_force).filled(Binance::Types::TimeInForce)
      optional(:quantity).filled(:decimal)
      optional(:price).filled(:decimal)
      optional(:quote_order_qty).filled(:decimal)

      optional(:new_client_order_id).filled(:string)
      optional(:stop_price).filled(:decimal)
      optional(:iceberg_qty).filled(:decimal)
      optional(:new_order_resp_type).filled(Types::OrderResponse)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end

    rule(:time_in_force) do
      if !key? && ([Binance::Types::OrderType["TAKE_PROFIT_LIMIT"], Binance::Types::OrderType["STOP_LOSS_LIMIT"], Binance::Types::OrderType["LIMIT"]]).include?(values[:type])
        key.failure("time_in_force is required")
      end

      key.failure("time_in_force must be GTC") if key? && values[:iceberg_qty] && values[:time_in_force] != Binance::Types::TimeInForce["GTC"]
    end

    rule do
      if values[:type] == Binance::Types::OrderType["MARKET"]
        base.failure("quantity or quote_order_qty is required") if values[:quantity].nil? && values[:quote_order_qty].nil? 
      end
    end

    rule(:quantity) do
      if values[:type] == Binance::Types::OrderType["MARKET"]
        key.failure("quantity is required") if !key? && !values[:quote_order_qty]
      elsif !key? && (Binance::Types::OrderType.values - ["MARKET"]).include?(values[:type])
        key.failure("quantity is required")
      end
    end

    rule(:quote_order_qty) do
      if values[:type] == Binance::Types::OrderType["MARKET"]
        key.failure("quote_order_qty is required") if !key? && !values[:quantity]
      end
    end

    rule(:price) do
      if !key? && ([Binance::Types::OrderType["LIMIT_MAKER"], Binance::Types::OrderType["TAKE_PROFIT_LIMIT"], Binance::Types::OrderType["STOP_LOSS_LIMIT"], Binance::Types::OrderType["LIMIT"]]).include?(values[:type])
        key.failure("price is required")
      end
    end

    rule(:stop_price) do
      if !key? && ([Binance::Types::OrderType["TAKE_PROFIT_LIMIT"], Binance::Types::OrderType["STOP_LOSS_LIMIT"], Binance::Types::OrderType["STOP_LOSS"], Binance::Types::OrderType["TAKE_PROFIT"]]).include?(values[:type])
        key.failure("stop_price is required")
      end
    end
  end

  class OrderInfoContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)

      optional(:order_id).filled(:integer, gt?: 0)
      optional(:orig_client_order_id).filled(:string)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end

    rule do
      base.failure("order_id or orig_client_order_id must be provided") if !values[:order_id] && !values[:orig_client_order_id]
    end
  end

  class CancelOrderContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)

      optional(:order_id).filled(:integer, gt?: 0)
      optional(:orig_client_order_id).filled(:string)
      optional(:new_client_order_id).filled(:string)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end

    rule do
      base.failure("order_id or orig_client_order_id must be provided") if !values[:order_id] && !values[:orig_client_order_id]
    end
  end

  class CancellAllOpenOrdersContact < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  class OpenOrdersContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  class AllOrdersContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)

      optional(:order_id).filled(:integer, gt?: 0)
      optional(:start_time).filled(:integer, gt?: 0)
      optional(:end_time).filled(:integer, gt?: 0)
      required(:limit).filled(Binance::Types::Limit)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end

    rule do
      #TODO: add specs
      if values[:start_time] && values[:end_time]
        base.failure("end_time must be greater than start_time") if values[:start_time] >= values[:end_time]
      end
    end
  end

  class NewOcoContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      required(:side).filled(Binance::Types::Side)

      optional(:list_client_order_id).filled(:string)

      optional(:limit_client_order_id).filled(:string)
      optional(:stop_client_order_id).filled(:string)

      optional(:quantity).filled(:decimal)
      required(:price).filled(:decimal)

      required(:stop_price).filled(:decimal)
      optional(:stop_limit_price).filled(:decimal)

      optional(:limit_iceberg_qty).filled(:decimal)
      optional(:stop_iceberg_qty).filled(:decimal)

      optional(:stop_limit_time_in_force).filled(Binance::Types::TimeInForce)

      optional(:new_order_resp_type).filled(Types::OrderResponse)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  class CancelOcoContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)

      optional(:order_list_id).filled(:integer)
      optional(:list_client_order_id).filled(:string)
      optional(:new_client_order_id).filled(:string)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  class OcoInfoContract < Dry::Validation::Contract
    params do
      optional(:order_list_id).filled(:integer)
      optional(:list_client_order_id).filled(:string)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  class AllOcoContract < Dry::Validation::Contract
    params do
      optional(:from_id).filled(:integer)
      optional(:start_time).filled(:integer, gt?: 0)
      optional(:end_time).filled(:integer, gt?: 0)
      required(:limit).filled(Binance::Types::Limit)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  class AllOpenOcoContract < Dry::Validation::Contract
    params do
      optional(:recv_window).filled(:integer, lteq?: 60000)
      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  # ACCOUNTS

  class AccountInfoContract < Dry::Validation::Contract
    params do
      optional(:recv_window).filled(:integer, lteq?: 60000)
      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  class AccountTradeListContract < Dry::Validation::Contract
    params do
      required(:symbol).filled(Binance::Types::Symbol)
      optional(:from_id).filled(:integer)
      optional(:start_time).filled(:integer, gt?: 0)
      optional(:end_time).filled(:integer, gt?: 0)
      optional(:limit).filled(Binance::Types::Limit)
      optional(:recv_window).filled(:integer, lteq?: 60000)

      required(:timestamp).filled(Binance::Types::Timestamp)
    end
  end

  # USER DATA STREAM

  class KeepAliveContract < Dry::Validation::Contract
    params do
      required(:listen_key).filled(:string)
    end
  end
end
