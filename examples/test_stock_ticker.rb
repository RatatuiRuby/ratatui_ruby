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
      @app.render
      assert buffer_content.any? { |line| line.include?("Network Activity") }
      assert buffer_content.any? { |line| line.include?("Stock Ticker") }
      # It's a dynamic simulation, so exact content varies,
      # but titles should be stable.
    end
  end

  def test_update
    # Render multiple times to ensure no crash on update
    with_test_terminal(60, 20) do
      @app.render
      @app.render
      assert buffer_content.any? { |line| line.include?("Stock Ticker") }
    end
  end
end
