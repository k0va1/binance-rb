# frozen_string_literal: true

RSpec.describe Binance::NewOrderContract do
  subject { described_class.new.call(params) }

  describe "limit order" do
    let(:valid_params) do 
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "LIMIT",
        time_in_force: "GTC",
        quantity: 10,
        price: 100,
        timestamp: 1000000
      }
    end

    context "with all required params" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when time_in_force is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:time_in_force) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:time_in_force]).to eq(["time_in_force is required"])
      end
    end

    context "when quantity is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:quantity) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:quantity]).to eq(["quantity is required"])
      end
    end

    context "when price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:price) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:price]).to eq(["price is required"])
      end
    end
  end

  describe "market order" do
    let(:valid_params) do
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "MARKET",
        quantity: 10,
        timestamp: 1000000
      }
    end

    context "with all required params" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when quantity is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:quantity) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[nil]).to eq(["quantity or quote_order_qty is required"])
      end

      context "when quote_order_qty is empty" do
        it "is invalid" do
          expect(subject.success?).to eq(false)
          expect(subject.errors[nil]).to eq(["quantity or quote_order_qty is required"])
        end
      end

      context "when quote_order_qty is present" do
        let(:params) { valid_params.tap { |p| p.delete(:quantity) }.merge(quote_order_qty: 100) }
        
        it "is valid" do
          expect(subject.success?).to eq(true)
        end
      end
    end
  end

  describe "stop loss" do
    let(:valid_params) do
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "STOP_LOSS",
        quantity: 10,
        stop_price: 10.0,
        timestamp: 1000000
      }
    end

    context "with all required params" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when quantity is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:quantity) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:quantity]).to eq(["quantity is required"])
      end
    end

    context "when stop_price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:stop_price) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:stop_price]).to eq(["stop_price is required"])
      end
    end
  end

  describe "stop loss limit" do
    let(:valid_params) do
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "STOP_LOSS_LIMIT",
        quantity: 10,
        time_in_force: "GTC",
        price: 100,
        stop_price: 10.0,
        timestamp: 1000000
      }
    end

    context "with all required params" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when quantity is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:quantity) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:quantity]).to eq(["quantity is required"])
      end
    end

    context "when stop_price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:stop_price) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:stop_price]).to eq(["stop_price is required"])
      end
    end

    context "when price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:price) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:price]).to eq(["price is required"])
      end
    end

    context "when time_in_force is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:time_in_force) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:time_in_force]).to eq(["time_in_force is required"])
      end
    end
  end

  describe "take profit" do
    let(:valid_params) do
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "TAKE_PROFIT",
        quantity: 10,
        stop_price: 10.0,
        timestamp: 1000000
      }
    end

    context "with all required params" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when quantity is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:quantity) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:quantity]).to eq(["quantity is required"])
      end
    end

    context "when stop_price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:stop_price) } }

      it "is invalid" do
        expect(subject.success?).to eq(false)
        expect(subject.errors[:stop_price]).to eq(["stop_price is required"])
      end
    end
  end

  describe "take profit limit" do
    let(:valid_params) do
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "TAKE_PROFIT_LIMIT",
        quantity: 10,
        time_in_force: "GTC",
        price: 100,
        stop_price: 10.0,
        timestamp: 1000000
      }
    end

    context "with all required params" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when quantity is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:quantity) } }

      it "is invalid" do
        expect(subject.errors[:quantity]).to eq(["quantity is required"])
        expect(subject.success?).to eq(false)
      end
    end

    context "when stop_price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:stop_price) } }

      it "is invalid" do
        expect(subject.errors[:stop_price]).to eq(["stop_price is required"])
        expect(subject.success?).to eq(false)
      end
    end

    context "when price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:price) } }

      it "is invalid" do
        expect(subject.errors[:price]).to eq(["price is required"])
        expect(subject.success?).to eq(false)
      end
    end

    context "when time_in_force is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:time_in_force) } }

      it "is invalid" do
        expect(subject.errors[:time_in_force]).to eq(["time_in_force is required"])
        expect(subject.success?).to eq(false)
      end
    end
  end

  describe "limit maker" do
    let(:valid_params) do 
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "LIMIT_MAKER",
        quantity: 10,
        price: 100,
        timestamp: 1000000
      }
    end

    context "with all required params" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when quantity is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:quantity) } }

      it "is invalid" do
        expect(subject.errors[:quantity]).to eq(["quantity is required"])
        expect(subject.success?).to eq(false)
      end
    end

    context "when price is empty" do
      let(:params) { valid_params.tap { |p| p.delete(:price) } }

      it "is invalid" do
        expect(subject.errors[:price]).to eq(["price is required"])
        expect(subject.success?).to eq(false)
      end
    end
  end

  context "with iceberg_qty" do
    let(:valid_params) do 
      {
        symbol: "BTC_USDT",
        side: "BUY",
        type: "LIMIT",
        time_in_force: "GTC",
        quantity: 10,
        price: 100,
        iceberg_qty: 0.0,
        timestamp: 1000000
      }
    end

    context "when iceberg_qty is present" do
      let(:params) { valid_params }

      it "is valid" do
        expect(subject.success?).to eq(true)
      end
    end

    context "when iceberg_qty is not GTC" do
      let(:params) { valid_params.merge(time_in_force: "FOK") }

      it "is valid" do
        expect(subject.errors[:time_in_force]).to eq(["time_in_force must be GTC"])
        expect(subject.success?).to eq(false)
      end
    end
  end
end
