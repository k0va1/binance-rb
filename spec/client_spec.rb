# frozen_string_literal: true

RSpec.describe Binance::Client do
  describe "#initialize" do
    context "configuration" do
      let(:client) do
        described_class.new do |c|
          c.api_key = "api_key"
          c.secret_key = "secret_key"
        end
      end

      it "reads configuration" do
        expect(client.configuration.api_key).to eq("api_key")
        expect(client.configuration.secret_key).to eq("secret_key")
      end
    end
  end

  describe "api methods" do
    let(:client) { described_class.new }

    describe "#ping" do
      before do
        stub_request(:get, "https://api.binance.com/api/v3/ping").
          to_return(status: 200, body: request_mock(:ping))
      end

      subject { client.ping }

      it "returns empty response" do
        expect(subject.status).to eq(200)
      end
    end

    describe "#time" do
      before do
        stub_request(:get, "https://api.binance.com/api/v3/time").
          to_return(status: 200, body: request_mock(:time))
      end

      subject { client.time }

      it "returns server time" do
        expect(subject.status).to eq(200)
        expect(subject.server_time).to eq(1499827319559)
      end
    end

    describe "#exchange_info" do
      before do
        stub_request(:get, "https://api.binance.com/api/v3/exchangeInfo").
          to_return(status: 200, body: request_mock(:exchange_info))
      end

      subject { client.exchange_info }

      it "returns exchange_info" do
        expect(subject.status).to eq(200)
        expect(subject.timezone).to eq("UTC")
        # rate limits
        expect(subject.rate_limits[0].rate_limit_type).to eq("REQUEST_WEIGHT")
        expect(subject.rate_limits[0].interval).to eq("MINUTE")
        expect(subject.rate_limits[0].interval_num).to eq(1)
        expect(subject.rate_limits[0].limit).to eq(1200)

        expect(subject.rate_limits[1].rate_limit_type).to eq("ORDERS")
        expect(subject.rate_limits[1].interval).to eq("SECOND")
        expect(subject.rate_limits[1].interval_num).to eq(1)
        expect(subject.rate_limits[1].limit).to eq(10)

        expect(subject.rate_limits[2].rate_limit_type).to eq("RAW_REQUESTS")
        expect(subject.rate_limits[2].interval).to eq("MINUTE")
        expect(subject.rate_limits[2].interval_num).to eq(5)
        expect(subject.rate_limits[2].limit).to eq(5000)

        # exchange filters
        expect(subject.exchange_filters[0].filter_type).to eq("EXCHANGE_MAX_NUM_ORDERS")
        expect(subject.exchange_filters[0].max_num_orders).to eq(1000)

        expect(subject.exchange_filters[1].filter_type).to eq("EXCHANGE_MAX_ALGO_ORDERS")
        expect(subject.exchange_filters[1].max_num_algo_orders).to eq(200)

        expect(subject.symbols.first.symbol).to eq("ETHBTC")
        expect(subject.symbols.first.status).to eq("TRADING")
        expect(subject.symbols.first.base_asset).to eq("ETH")
        expect(subject.symbols.first.base_asset_precision).to eq(8)
        expect(subject.symbols.first.quote_asset).to eq("BTC")
        expect(subject.symbols.first.quote_precision).to eq(8)
        expect(subject.symbols.first.base_commission_precision).to eq(8)
        expect(subject.symbols.first.quote_commission_precision).to eq(8)
        expect(subject.symbols.first.order_types).to eq([ "LIMIT", "LIMIT_MAKER", "MARKET", "STOP_LOSS", "STOP_LOSS_LIMIT", "TAKE_PROFIT", "TAKE_PROFIT_LIMIT" ]) 
        expect(subject.symbols.first.iceberg_allowed).to eq(true) 
        expect(subject.symbols.first.oco_allowed).to eq(true) 
        expect(subject.symbols.first.quote_order_qty_market_allowed).to eq(true) 
        expect(subject.symbols.first.is_spot_trading_allowed).to eq(true) 
        expect(subject.symbols.first.is_margin_trading_allowed).to eq(true) 
        expect(subject.symbols.first.filters[0].filter_type).to eq("PRICE_FILTER") 
        expect(subject.symbols.first.filters[0].min_price).to eq("0.00000100") 
        expect(subject.symbols.first.filters[0].max_price).to eq("100000.00000000") 
        expect(subject.symbols.first.filters[0].tick_size).to eq("0.00000100") 
        expect(subject.symbols.first.filters[1].filter_type).to eq("PERCENT_PRICE")
        expect(subject.symbols.first.filters[1].multiplier_up).to eq("5")
        expect(subject.symbols.first.filters[1].multiplier_down).to eq("0.2")
        expect(subject.symbols.first.filters[1].avg_price_mins).to eq(5)
        expect(subject.symbols.first.filters[2].filter_type).to eq("LOT_SIZE")
        expect(subject.symbols.first.filters[2].min_qty).to eq("0.00100000")
        expect(subject.symbols.first.filters[2].max_qty).to eq("100000.00000000")
        expect(subject.symbols.first.filters[2].step_size).to eq("0.00100000")
        expect(subject.symbols.first.filters[3].filter_type).to eq("MIN_NOTIONAL")
        expect(subject.symbols.first.filters[3].min_notional).to eq("0.00010000")
        expect(subject.symbols.first.filters[3].apply_to_market).to eq(true)
        expect(subject.symbols.first.filters[3].avg_price_mins).to eq(5)
        expect(subject.symbols.first.filters[4].filter_type).to eq("ICEBERG_PARTS")
        expect(subject.symbols.first.filters[4].limit).to eq(10)
        expect(subject.symbols.first.filters[5].filter_type).to eq("MARKET_LOT_SIZE")
        expect(subject.symbols.first.filters[5].min_qty).to eq("0.00000000")
        expect(subject.symbols.first.filters[5].max_qty).to eq("2909.39325988")
        expect(subject.symbols.first.filters[5].step_size).to eq("0.00000000")
        expect(subject.symbols.first.filters[6].filter_type).to eq("MAX_NUM_ORDERS")
        expect(subject.symbols.first.filters[6].max_num_orders).to eq(200)
        expect(subject.symbols.first.filters[7].filter_type).to eq("MAX_NUM_ALGO_ORDERS")
        expect(subject.symbols.first.filters[7].max_num_algo_orders).to eq(5)
        expect(subject.symbols.first.permissions).to eq([ "SPOT", "MARGIN" ])
      end
    end

    describe "#depth" do
      before do
        stub_request(:get, "https://api.binance.com/api/v3/depth")
          .with(query: { "symbol": "BTC_USDT", "limit": "100" })
          .to_return(status: 200, body: request_mock(:depth))
      end

      subject { client.depth(symbol: "BTC_USDT") }

      it "returns depth" do
        expect(subject.status).to eq(200)
        expect(subject.bids).to eq([["4.00000000", "431.00000000"]])
        expect(subject.asks).to eq([["4.00000200", "12.00000000"]])
      end

      context "with invalid params" do
        subject { client.depth(symbol: "aaa") }

        it "raises ivalid params error" do
          expect { subject }.to raise_error(Binance::InvalidParamsError)
        end
      end
    end

    describe "#trades" do
      before do
        stub_request(:get, "https://api.binance.com/api/v3/trades")
          .with(query: { "symbol": "BTC_USDT", "limit": "500" })
          .to_return(status: 200, body: request_mock(:trades))
      end

      subject { client.trades(symbol: "BTC_USDT") }

      it "returns trades" do
        expect(subject.status).to eq(200)
        expect(subject.trades.first.id).to eq(28457)
        expect(subject.trades.first.price).to eq("4.00000100")
        expect(subject.trades.first.qty).to eq("12.00000000")
        expect(subject.trades.first.quote_qty).to eq("48.000012")
        expect(subject.trades.first.time).to eq(1499865549590)
        expect(subject.trades.first.is_buyer_maker).to eq(true)
        expect(subject.trades.first.is_best_match).to eq(true)
      end

      context "with invalid params" do
        subject { client.trades(symbol: "aaa") }

        it "raises ivalid params error" do
          expect { subject }.to raise_error(Binance::InvalidParamsError)
        end
      end
    end

    describe "#historical_trades" do
      before do
        stub_request(:get, "https://api.binance.com/api/v3/historicalTrades")
          .with(query: { "symbol": "BTC_USDT", "limit": "500", "fromId": "100" })
          .to_return(status: 200, body: request_mock(:trades))
      end

      subject { client.historical_trades(symbol: "BTC_USDT", from_id: 100) }

      it "returns historical trades" do
        expect(subject.status).to eq(200)
        expect(subject.trades.first.id).to eq(28457)
        expect(subject.trades.first.price).to eq("4.00000100")
        expect(subject.trades.first.qty).to eq("12.00000000")
        expect(subject.trades.first.quote_qty).to eq("48.000012")
        expect(subject.trades.first.time).to eq(1499865549590)
        expect(subject.trades.first.is_buyer_maker).to eq(true)
        expect(subject.trades.first.is_best_match).to eq(true)
      end

      context "with invalid params" do
        subject { client.historical_trades(symbol: "aaa", from_id: 100) }

        it "raises ivalid params error" do
          expect { subject }.to raise_error(Binance::InvalidParamsError)
        end
      end
    end

    describe "#agg_trades" do
      before do
        stub_request(:get, "https://api.binance.com/api/v3/aggTrades")
          .with(query: { "symbol": "BTC_USDT", "limit": "500" })
          .to_return(status: 200, body: request_mock(:agg_trades))
      end

      subject { client.agg_trades(symbol: "BTC_USDT") }

      it "returns agg trades" do
        expect(subject.status).to eq(200)
        expect(subject.agg_trades.first.agg_trade_id).to eq(26129)
        expect(subject.agg_trades.first.price).to eq("0.01633102")
        expect(subject.agg_trades.first.qty).to eq("4.70443515")
        expect(subject.agg_trades.first.first_trade_id).to eq(27781)
        expect(subject.agg_trades.first.last_trade_id).to eq(27781)
        expect(subject.agg_trades.first.timestamp).to eq(1498793709153)
        expect(subject.agg_trades.first.is_buyer_maker).to eq(true)
        expect(subject.agg_trades.first.is_best_price_match).to eq(true)
      end

      context "with invalid params" do
        subject { client.historical_trades(symbol: "aaa", from_id: 100) }

        it "raises ivalid params error" do
          expect { subject }.to raise_error(Binance::InvalidParamsError)
        end
      end

    end

    describe "#klines" do

    end

    describe "#avg_price" do

    end

    describe "#price_change_24h" do
      context "when symbol" do
        before do
          stub_request(:get, "https://api.binance.com/api/v3/ticker/24hr")
            .with(query: { "symbol": "BNBBTC" })
            .to_return(status: 200, body: request_mock(:price_change_24))
        end

        subject { client.price_change_24h(symbol: "BNBBTC") }

        it "returns price change 24h" do
          expect(subject.status).to eq(200)
          expect(subject.symbol).to eq("BNBBTC")
          expect(subject.price_change).to eq("-94.99999800")
          expect(subject.price_change_percent).to eq("-95.960")
          expect(subject.weighted_avg_price).to eq("0.29628482")
          expect(subject.prev_close_price).to eq("0.10002000")
          expect(subject.last_price).to eq("4.00000200")
          expect(subject.last_qty).to eq("200.00000000")
          expect(subject.bid_price).to eq("4.00000000")
          expect(subject.ask_price).to eq("4.00000200")
          expect(subject.open_price).to eq("99.00000000")
          expect(subject.high_price).to eq("100.00000000")
          expect(subject.low_price).to eq("0.10000000")
          expect(subject.volume).to eq("8913.30000000")
          expect(subject.quote_volume).to eq("15.30000000")
          expect(subject.open_time).to eq(1499783499040)
          expect(subject.close_time).to eq(1499869899040)
          expect(subject.first_id).to eq(28385)
          expect(subject.last_id).to eq(28460)
          expect(subject.count).to eq(76)
        end
      end

      context "without symbol" do
        before do
          stub_request(:get, "https://api.binance.com/api/v3/ticker/24hr")
            .to_return(status: 200, body: "[#{request_mock(:price_change_24)}]")
        end

        subject { client.price_change_24h }

        it "returns array of price change 24h" do
          expect(subject.status).to eq(200)
          expect(subject.items.first.symbol).to eq("BNBBTC")
          expect(subject.items.first.price_change).to eq("-94.99999800")
          expect(subject.items.first.price_change_percent).to eq("-95.960")
          expect(subject.items.first.weighted_avg_price).to eq("0.29628482")
          expect(subject.items.first.prev_close_price).to eq("0.10002000")
          expect(subject.items.first.last_price).to eq("4.00000200")
          expect(subject.items.first.last_qty).to eq("200.00000000")
          expect(subject.items.first.bid_price).to eq("4.00000000")
          expect(subject.items.first.ask_price).to eq("4.00000200")
          expect(subject.items.first.open_price).to eq("99.00000000")
          expect(subject.items.first.high_price).to eq("100.00000000")
          expect(subject.items.first.low_price).to eq("0.10000000")
          expect(subject.items.first.volume).to eq("8913.30000000")
          expect(subject.items.first.quote_volume).to eq("15.30000000")
          expect(subject.items.first.open_time).to eq(1499783499040)
          expect(subject.items.first.close_time).to eq(1499869899040)
          expect(subject.items.first.first_id).to eq(28385)
          expect(subject.items.first.last_id).to eq(28460)
          expect(subject.items.first.count).to eq(76)
        end
      end
    end
  end
end
