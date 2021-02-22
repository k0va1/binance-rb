# frozen_string_literal: true

require "binance/version"
require "binance/configuration"
require "binance/http_client"
require "binance/signed_http_client"
require "binance/api_key_client"
require "binance/request_types"
require "binance/response_types"
require "binance/errors"

module Binance
  class Client
    attr_reader :configuration

    def initialize(api_key = nil, secret_key = nil)
      @configuration = Configuration.new(api_key, secret_key)
      yield(configuration) if block_given?
    end

    def prefix
      "api/v3"
    end

    def ping
      http_client_factory.get("ping")
    end

    def time
      resp = http_client_factory.get("time")
      map_response(resp, Binance::TimeResponse)
    end

    def exchange_info
      resp = http_client_factory.get("exchangeInfo")
      map_response(resp, Binance::ExchangeInfoResponse)
    end

    def depth(params)
      validated_params = Binance::DepthParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("depth", params: validated_params)
      map_response(resp, Binance::DepthResponse)
    end

    def trades(params)
      validated_params = Binance::TradesParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("trades", params: validated_params)
      map_response(resp,nil, Binance::TradesResponse, :trades)
    end

    def historical_trades(params)
      validated_params = HistoricalTradesParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("historicalTrades", params: camelize_params(validated_params.to_h))
      map_response(resp,nil, Binance::TradesResponse, :trades)
    end

    def agg_trades(params)
      validated_params = AggTradesParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("aggTrades", params: camelize_params(validated_params.to_h))
      map_response(resp,nil, Binance::AggTradesResponse, :agg_trades)
    end

    def klines(params)
      validated_params = Binance::KlinesParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("klines", params: validated_params)
      map_response(resp, nil, Binance::KlinesResponse, :klines)
    end

    def avg_price(params)
      validated_params = Binance::AvgPriceParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("avgPrice", params: validated_params)
      map_response(resp, AvgPriceResponse)
    end

    def price_change_24h(params = {})
      validated_params = Binance::PriceChange24ParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("ticker/24hr", params: validated_params)
      map_response(
        resp,
        Binance::PriceChange24Response,
        Binance::PriceChange24ArrayResponse
      )
    end

    def symbol_price(params = {})
      validated_params = Binance::SymbolPriceParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("ticker/price", params: validated_params)
      map_response(
        resp,
        Binance::SymbolPriceResponse,
        Binance::SymbolPriceArrayResponse,
        :symbols
      )
    end

    def order_book_ticker(params = {})
      validated_params = Binance::OrderBookTickerParamsSchema.call(**params)
      raise ::Binance::InvalidParamsError if validated_params.failure?

      resp = http_client_factory.get("ticker/bookTicker", params: validated_params)
      map_response(
        resp,
        Binance::OrderBookItemResponse,
        Binance::OrderBookItemArrayResponse,
        :order_book_items
      )
    end

    # account endpoints

    def create_order(symbol, side, type)
      case type
      when 'MARKET'
        params = NewMarketOrderParams.new(
          symbol: symbol
        )
      end

      http_client_factory.post("order", params: params)
    end

    def order_info(symbol, order_id = nil, orig_client_order_id = nil, recv_window = nil)
      params = OrderInfoParams.new(
        symbol: symbol,
        order_id: order_id,
        orig_client_order_id: orig_client_order_id,
        recv_window: recv_window
      )

      http_client_factory.get("order", params: params)
    end

    def cancel_order(symbol, order_id = nil, orig_client_order_id = nil, new_client_order_id = nil, recv_window = nil)
      params = CancelOrderContract.call(
        symbol: symbol,
        order_id: order_id,
        orig_client_order_id: orig_client_order_id,
        new_client_order_id: new_client_order_id,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.delete("order", params: params)
    end

    def cancel_open_orders(symbol, recv_window = nil)
      params = CancellAllOpenOrdersContact.call(
        symbol: symbol,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.delete("openOrders", params: params)
    end

    def open_orders(symbol, recv_window = nil)
      params = OpenOrdersContract.call(
        symbol: symbol,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.get("openOrders", params: params)
    end

    def all_orders(symbol, order_id = nil, start_time = nil, end_time = nil, limit = nil, recv_window = nil)
      params = yield validate_params(params, contract: OpenOrdersContract)
      params = OpenOrdersContract.call(
        symbol: symbol,
        order_id: order_id,
        start_time: start_time,
        end_time: end_time,
        limit: limit,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.get("allOrders", params: params)
    end

    def create_oco_order
    end

    def cancel_oco_order(symbol, order_list_id = nil, list_client_order_id = nil, new_client_order_id = nil, recv_window = nil)
      params = CancelOcoContract.call(
        symbol: symbol,
        order_list_id: order_list_id,
        list_client_order_id: list_client_order_id,
        new_client_order_id: new_client_order_id,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.delete("orderList", params: params)
    end

    def oco_order_info(order_list_id = nil, orig_client_order_id = nil, recv_window = nil)
      params = OcoInfoContract.call(
        order_list_id: order_list_id,
        orig_client_order_id: orig_client_order_id,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.get("orderList", params: params)
    end

    def all_oco_orders(from_id = nil, start_time = nil, end_time = nil, limit = nil, recv_window = nil)
      params = AllOcoContract.call(
        from_id: from_id,
        start_time: start_time,
        end_time: end_time,
        limit: limit,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.get("allOrderList", params: params)
    end

    def oco_order_info(recv_window = nil)
      params = OcoInfoContract.call(
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.get("openOrderList", params: params)
    end

    def account_info(recv_window = nil)
      params = AccountInfoContract.call(
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.get("account", params: params)
    end

    def trade_list(symbol, start_time = nil, end_time = nil, from_id = nil, limit = nil, recv_window = nil)
      params = AccountTradeListContract.call(
        symbol: symbol, 
        start_time: start_time,
        end_time: end_time,
        from_id: from_id,
        limit: limit,
        recv_window: recv_window
      )
      raise ::Binance::InvalidParamsError if params.failure?

      http_client_factory.get("myTrades", params: params)
    end

    def start_data_stream
      http_client_factory.get("userDataStream")
    end

    def keepalive_data_stream(listen_key)
      http_client_factory.put("userDataStream")
    end

    def close_data_stream
      http_client_factory.delete("userDataStream")
    end

    private

    # Endpoint security type
    # * Each endpoint has a security type that determines the how you will
    #   interact with it. This is stated next to the NAME of the endpoint.
    #     * If no security type is stated, assume the security type is NONE.
    # * API-keys are passed into the Rest API via the `X-MBX-APIKEY`
    #   header.
    # * API-keys and secret-keys **are case sensitive**.
    # * API-keys can be configured to only access certain types of secure endpoints.
    #  For example, one API-key could be used for TRADE only, while another API-key
    #  can access everything except for TRADE routes.
    # * By default, API-keys can access all secure routes.
    # 
    # Security Type | Description
    # ------------ | ------------
    # NONE | Endpoint can be accessed freely.
    # TRADE | Endpoint requires sending a valid API-Key and signature.
    # USER_DATA | Endpoint requires sending a valid API-Key and signature.
    # USER_STREAM | Endpoint requires sending a valid API-Key.
    # MARKET_DATA | Endpoint requires sending a valid API-Key.
    # TOOO: add all client methods to values
    ENDPOINTS_SECURITY_MAPPING = {
        none: %w[ping time exchange_info symbol_price klines price_change_24h depth agg_trades trades avg_price order_book_ticker],
        trade: %w[create_order cancel_order cancel_open_orders cancel_oco_order create_oco_order],
        user_data: %w[order_info open_orders],
        user_stream: %w[],
        market_data: %w[historical_trades]
    }.freeze
    def http_client_factory
      callee = caller_locations.first.label
      security_type = ENDPOINTS_SECURITY_MAPPING.find { |_,v| v.include?(callee) }&.first

      case security_type
      when :none
        @http_client ||= Binance::HttpClient.new(configuration, prefix)
      when :trade, :user_data
        @signed_http_client ||= Binance::SignedHttpClient.new(configuration, prefix)
      when :user_stream, :market_data
        @api_key_client ||= Binance::ApiKeyClient.new(configuration, prefix)
      else
        raise "current method has not supported yet"
      end
    end

    def camelize_params(params)
      params.transform_keys { |k| k.to_s.gsub(/_([a-zA-Z])/) { $1.upcase } }
    end

    def map_response(res, response_class, array_response_class = nil, array_key = :items)
      parsed_body = JSON.parse(res.body)

      if res.success?
        case parsed_body
        when Array
          # TODO: refactor this shit
          if array_response_class == KlinesResponse
            keys = Binance::Kline.schema.keys.map(&:name)
            parsed_body.map! { |kl| Hash[*keys.zip(kl).flatten] }
          end

          array_response_class.new(
            status: res.status,
            headers: res.headers,
            array_key => parsed_body
          )
        when Hash
          response_class.new(
            status: res.status,
            headers: res.headers,
            **parsed_body
          )
        end
      else
        ErrorResponse.new(
          status: res.status,
          headers: res.headers,
          **parsed_body
        )
      end
    end
  end
end

# binance testnet credentials
# require "binance/client"
# client = Binance::Client.new do |c|
#   c.api_key = "brza5CuVYwhMC0bopCUX8ivhlBL8SvMMViybNnigBBBhfPxT5ZfVT3NHyamiLnZb"
#   c.secret_key = "VHCwOfaRQSswaHdS62fqbV0zLGcn1fl5EhlufhUwkF39F1T10Ojd5byPnftSglEA"
# end
# client.exchange_info
#
# futures_client = Binance::Futures::Client.new do |c|
#   c.api_key = "api_key"
#   c.secret_key = "secret_key"
# end
#
# margin_client = Binance::Margin::Client.new do |c|
#   c.api_key = "api_key"
#   c.secret_key = "secret_key"
# end
#
# withdrawal_client = Binance::Withdrawal::Client.new do |c|
#   c.api_key = "api_key"
#   c.secret_key = "secret_key"
# end
