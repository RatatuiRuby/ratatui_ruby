# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

class SystemMonitorApp
  def initialize
    @percentage = 50
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  def render
    # System Monitor Layout
    # Top: Table (50%)
    # Bottom: Gauge (50%)

    header_style = RatatuiRuby::Style.new(fg: :blue, modifiers: [:bold])

    header = [
      RatatuiRuby::Paragraph.new(text: "PID", style: header_style),
      RatatuiRuby::Paragraph.new(text: "Name", style: header_style),
      RatatuiRuby::Paragraph.new(text: "CPU%", style: header_style),
      RatatuiRuby::Paragraph.new(text: "Mem%", style: header_style),
    ]

    rows = [
      ["1234", "ruby", "0.5", "1.2"],
      ["5678", "rust", "10.2", "4.5"],
      ["9012", "system", "1.1", "0.8"],
    ]

    widths = [
      RatatuiRuby::Constraint.length(10),
      RatatuiRuby::Constraint.min(20),
      RatatuiRuby::Constraint.length(10),
      RatatuiRuby::Constraint.length(10),
    ]

    table = RatatuiRuby::Table.new(
      header:,
      rows:,
      widths:,
      block: RatatuiRuby::Block.new(title: "Processes", borders: [:all])
    )

    gauge = RatatuiRuby::Gauge.new(
      ratio: @percentage / 100.0,
      label: "#{@percentage}%",
      style: RatatuiRuby::Style.new(fg: :green),
      block: RatatuiRuby::Block.new(title: "Memory Usage", borders: [:all])
    )

    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      children: [table, gauge],
      constraints: [
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(50),
      ]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    if event
      case event[:code]
      when "q"
        :quit
      when "up"
        @percentage = [@percentage + 5, 100].min
      when "down"
        @percentage = [@percentage - 5, 0].max
      end
    end
  end
end

SystemMonitorApp.new.run if __FILE__ == $0
