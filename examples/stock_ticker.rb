# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Simulate a stock ticker
class StockTickerApp
  def initialize
    @network_data = Array.new(50) { rand(0..10) }
    @ruby_stock = []
    @rust_stock = []
    @counter = 0
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
        sleep 0.1
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  def render
    # Update data
    @counter += 1
    @network_data.shift
    @network_data << rand(0..10)

    ruby_val = 50.0 + (Math.sin(@counter * 0.1) * 20.0) + (rand * 5.0)
    rust_val = 40.0 + (Math.cos(@counter * 0.2) * 15.0) + (rand * 10.0)

    @ruby_stock << [@counter.to_f, ruby_val]
    @rust_stock << [@counter.to_f, rust_val]

    # Keep only last 100 points
    if @ruby_stock.length > 100
      @ruby_stock.shift
      @rust_stock.shift
    end

    # Define UI
    ui = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.new(type: :percentage, value: 20),
        RatatuiRuby::Constraint.new(type: :percentage, value: 80),
      ],
      children: [
        RatatuiRuby::Sparkline.new(
          data: @network_data,
          style: RatatuiRuby::Style.new(fg: :cyan),
          block: RatatuiRuby::Block.new(title: "Network Activity", borders: :all)
        ),
        RatatuiRuby::Chart.new(
          datasets: [
            RatatuiRuby::Dataset.new(name: "RBY", data: @ruby_stock, color: :green),
            RatatuiRuby::Dataset.new(name: "RST", data: @rust_stock, color: :red),
          ],
          x_axis: RatatuiRuby::Axis.new(
            title: "Time",
            bounds: [((@counter > 100) ? @counter - 100.0 : 0.0), @counter.to_f],
            labels: [@counter.to_s]
          ),
          y_axis: RatatuiRuby::Axis.new(
            title: "Price",
            bounds: [0.0, 100.0],
            labels: %w[0 50 100]
          ),
          block: RatatuiRuby::Block.new(title: "Stock Ticker", borders: :all),
        ),
      ]
    )

    RatatuiRuby.draw(ui)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    :quit if event == "q" || event == :ctrl_c
  end
end

StockTickerApp.new.run if __FILE__ == $0
