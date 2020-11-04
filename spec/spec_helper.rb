# frozen_string_literal: true

begin
  require "pry"
  require "pry-byebug"
rescue LoadError
end

require "binance/client"
require 'webmock/rspec'

SPEC_ROOT = Pathname(__dir__)

Dir[SPEC_ROOT.join("support/**/*.rb")].each(&method(:require))

module Helpers
  def request_mock(name)
    File.read("#{SPEC_ROOT}/support/request_mocks/#{name}.json")
  end
end

RSpec.configure do |config|
  config.include Helpers
end
