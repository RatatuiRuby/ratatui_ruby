# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class SystemMonitorApp
  def initialize
    @percentage = 50
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private

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

    main_layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      children: [
        RatatuiRuby::Table.new(
          header:,
          rows:,
          widths:,
          block: RatatuiRuby::Block.new(title: "Processes", borders: [:all])
        ),
        RatatuiRuby::Gauge.new(
          percent: @percentage,
          label: "#{@percentage}%",
          style: RatatuiRuby::Style.new(fg: :green),
          block: RatatuiRuby::Block.new(title: "Memory Usage", borders: [:all])
        ),
      ],
      constraints: [
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(50),
      ]
    )

    # Sidebar
    sidebar = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "GENERAL", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "q: Quit",
            "",
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "GAUGE", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "↑: Increase (#{@percentage}%)",
            "↓: Decrease",
          ].flatten
        )
      ]
    )

    # Full layout with sidebar
    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.new(type: :percentage, value: 70),
        RatatuiRuby::Constraint.new(type: :percentage, value: 30),
      ],
      children: [main_layout, sidebar]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "up"
      @percentage = [@percentage + 5, 100].min
    in type: :key, code: "down"
      @percentage = [@percentage - 5, 0].max
    else
      nil
    end
  end
end

SystemMonitorApp.new.run if __FILE__ == $0
