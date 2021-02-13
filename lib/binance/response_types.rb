# frozen_string_literal: true

require "dry/struct"
require_relative "types"

module Binance
  BaseStruct = Class.new(Dry::Struct) do
    transform_keys(-> (k){ k.to_s.gsub(/(.)([A-Z])/,'\1_\2').downcase.to_sym })
  end

  BaseResponse = Class.new(BaseStruct) do
    attribute :status, Types::Strict::Integer
    attribute :headers, Types::Strict::Hash
  end

  ErrorResponse = Class.new(BaseResponse) do
    attribute :code, Types::Integer
    attribute :msg, Types::String
  end

  # filters
  Filter = Class.new(BaseStruct) do
    attribute :filter_type, Types::String
  end

  PriceFilter = Class.new(Filter) do
    attribute :min_price, Types::String
    attribute :max_price, Types::String
    attribute :tick_size, Types::String
  end

  PercentPrice = Class.new(Filter) do
    attribute :multiplier_up, Types::String
    attribute :multiplier_down, Types::String
    attribute :avg_price_mins, Types::Integer
  end

  LotSize = Class.new(Filter) do
    attribute :min_qty, Types::String
    attribute :max_qty, Types::String
    attribute :step_size, Types::String
  end

  MinNotional = Class.new(Filter) do
    attribute :min_notional, Types::String
    attribute :apply_to_market, Types::Bool
    attribute :avg_price_mins, Types::Integer
  end

  IcebergParts = Class.new(Filter) do
    attribute :limit, Types::Integer
  end

  MarketLotSize = Class.new(LotSize)

  MaxNumOrders = Class.new(Filter) do
    attribute :max_num_orders, Types::Integer
  end

  MaxNumAlgoOrders = Class.new(Filter) do
    attribute :max_num_algo_orders, Types::Integer
  end

  MaxNumIcebergOrders = Class.new(Filter) do
    attribute :max_num_iceberg_orders, Types::Integer
  end

  MaxPositionFilter = Class.new(Filter) do
    attribute :max_position, Types::String
  end

  ExchangeMaxNumOrders = Class.new(Filter) do
    attribute :max_num_orders, Types::Integer
  end

  ExchangeMaxNumAlgoOrders = Class.new(Filter) do
    attribute :max_num_algo_orders, Types::Integer
  end

  SymbolFilters = Types::Array.of(PriceFilter | PercentPrice | LotSize | MinNotional | IcebergParts | MarketLotSize | MaxNumOrders | MaxNumAlgoOrders | MaxNumIcebergOrders | MaxPositionFilter)
  ExchangeFilters = Types::Array.of(ExchangeMaxNumOrders | ExchangeMaxNumAlgoOrders)

  # endpoints responses
  TimeResponse = Class.new(BaseResponse) do
    attribute :server_time, Types::Integer
  end

  ExchangeInfoResponse = Class.new(BaseResponse) do
    attribute :server_time, Types::Integer
    attribute :timezone, Types::String
    attribute :rate_limits, Types::Array do
      attribute :rate_limit_type, Types::String
      attribute :interval, Types::String
      attribute :interval_num, Types::Integer
      attribute :limit, Types::Integer
    end
    attribute :exchange_filters, ExchangeFilters
    attribute :symbols, Types::Array do
      attribute :symbol, Binance::Types::Symbol
      attribute :status, Types::String
      attribute :base_asset, Types::String
      attribute :base_asset_precision, Types::Integer
      attribute :quote_asset, Types::String
      attribute :quote_precision, Types::Integer
      attribute :base_commission_precision, Types::Integer
      attribute :quote_commission_precision, Types::Integer
      attribute :order_types, Types::Array.of(Binance::Types::OrderType)
      attribute :iceberg_allowed, Types::Bool
      attribute :oco_allowed, Types::Bool
      attribute :quote_order_qty_market_allowed, Types::Bool
      attribute :is_spot_trading_allowed, Types::Bool
      attribute :is_margin_trading_allowed, Types::Bool
      attribute :filters, SymbolFilters
      attribute :permissions, Types::Array.of(Types::String)
    end
  end

  DepthResponse = Class.new(BaseResponse) do
    attribute :last_update_id, Types::Integer
    attribute :bids, Types::Array.of(Types::Array.of(Types::String))
    attribute :asks, Types::Array.of(Types::Array.of(Types::String))
  end

  # trades

  Trade = Class.new(BaseStruct) do
    attribute :id, Types::Integer
    attribute :price, Types::String
    attribute :qty, Types::String
    attribute :quote_qty, Types::String
    attribute :time, Types::Integer
    attribute :is_buyer_maker, Types::Bool
    attribute :is_best_match, Types::Bool
  end

  TradesResponse = Class.new(BaseResponse) do
    attribute :trades, Types::Array.of(Binance::Trade)
  end

  AggTrade = Class.new(BaseStruct) do
    transform_keys do |k|
      case k
      when "a"
        :agg_trade_id
      when "p"
        :price
      when "q"
        :qty
      when "f"
        :first_trade_id
      when "l"
        :last_trade_id
      when "T"
        :timestamp
      when "m"
        :is_buyer_maker
      when "M"
        :is_best_price_match
      end
    end

    attribute :agg_trade_id, Types::Integer
    attribute :price, Types::String
    attribute :qty, Types::String
    attribute :first_trade_id, Types::Integer
    attribute :last_trade_id, Types::Integer
    attribute :timestamp, Types::Integer
    attribute :is_buyer_maker, Types::Bool
    attribute :is_best_price_match, Types::Bool
  end

  AggTradesResponse = Class.new(BaseResponse) do
    attribute :agg_trades, Types::Array.of(Binance::AggTrade)
  end

  PriceChange24 = Class.new(BaseStruct) do
    attribute :symbol, Binance::Types::Symbol
    attribute :price_change, Types::String
    attribute :price_change_percent, Types::String
    attribute :weighted_avg_price, Types::String
    attribute :prev_close_price, Types::String
    attribute :last_price, Types::String
    attribute :last_qty, Types::String
    attribute :bid_price, Types::String
    attribute :ask_price, Types::String
    attribute :open_price, Types::String
    attribute :high_price, Types::String
    attribute :low_price, Types::String
    attribute :volume, Types::String
    attribute :quote_volume, Types::String
    attribute :open_time, Types::Integer
    attribute :close_time, Types::Integer
    attribute :first_id, Types::Integer
    attribute :last_id, Types::Integer
    attribute :count, Types::Integer
  end

  PriceChange24Response = Class.new(PriceChange24) do
    attribute :status, Types::Strict::Integer
    attribute :headers, Types::Strict::Hash
  end

  PriceChange24ArrayResponse = Class.new(BaseResponse) do
    attribute :items, Types::Array.of(PriceChange24)
  end

  # convert binance hueta to named attributes
  Kline = Class.new(BaseStruct) do
    attribute :open_time, Types::Integer
    attribute :open, Types::String
    attribute :high, Types::String
    attribute :low, Types::String
    attribute :close, Types::String
    attribute :volume, Types::String
    attribute :close_time, Types::Integer
    attribute :quote_asset_volume, Types::String
    attribute :number_of_trades, Types::Integer
    attribute :taker_buy_base_asset_volume, Types::String
    attribute :taker_buy_quote_asset_volume, Types::String
    attribute :ignore, Types::String
  end

  KlinesResponse = Class.new(BaseResponse) do
    attribute :klines, Types::Array.of(Binance::Kline)
  end
end
