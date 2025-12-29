# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "stock_ticker"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestStockTicker < Minitest::Test
  def setup
    @app = StockTickerApp.new
  end

  def test_render
    with_test_terminal(60, 20) do
      # Queue quit
      inject_key(:q)
      
      # Stub sleep to speed up test
      @app.stub :sleep, nil do
        @app.run
      end

      assert buffer_content.any? { |line| line.include?("Network Activity") }
      assert buffer_content.any? { |line| line.include?("Stock Ticker") }
    end
  end

  def test_update
    with_test_terminal(60, 20) do
      # Ensure the main loop runs and renders at least once
      inject_key(:q)

      @app.stub :sleep, nil do
        @app.run
      end

      assert buffer_content.any? { |line| line.include?("Stock Ticker") }
    end
  end
end
