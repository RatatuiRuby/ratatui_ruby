# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Chart Demo
# Demonstrates Scatter and Line datasets in a single Chart.
class ChartDemoApp
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

  private

  def render
    # Scatter data: Random points
    scatter_data = Array.new(20) { [rand(0.0..10.0), rand(-1.0..1.0)] }

    # Line data: Sine wave
    line_data = (0..100).map do |i|
      x = i / 10.0
      [x, Math.sin(x)]
    end

    datasets = [
      RatatuiRuby::Dataset.new(
        name: "Scatter",
        data: scatter_data,
        color: "red",
        marker: :dot,
        graph_type: :scatter,
      ),
      RatatuiRuby::Dataset.new(
        name: "Line",
        data: line_data,
        color: "green",
        marker: :braille,
        graph_type: :line,
      ),
    ]

    chart = RatatuiRuby::Chart.new(
      datasets:,
      x_axis: RatatuiRuby::Axis.new(
        title: "Time",
        bounds: [0.0, 10.0],
        labels: %w[0 5 10],
        style: RatatuiRuby::Style.new(fg: :yellow),
      ),
      y_axis: RatatuiRuby::Axis.new(
        title: "Amplitude",
        bounds: [-1.0, 1.0],
        labels: %w[-1 0 1],
        style: RatatuiRuby::Style.new(fg: :cyan),
      ),
      block: RatatuiRuby::Block.new(
        title: "Chart Demo (Q to quit)",
        borders: [:all],
      ),
    )

    RatatuiRuby.draw(chart)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return nil unless event

    return :quit if event == "q" || event == :ctrl_c
    nil
  end
end

ChartDemoApp.new.run if __FILE__ == $PROGRAM_NAME
