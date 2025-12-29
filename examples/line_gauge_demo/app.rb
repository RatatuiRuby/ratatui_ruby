# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates LineGauge widget with various configurations and ratios
class LineGaugeDemoApp
  def initialize
    @ratios = [0.2, 0.5, 0.8]
    @ratio_index = 0
  end

  def run
    RatatuiRuby.run do
      loop do
        draw
        event = RatatuiRuby.poll_event
        break if event == "q" || event == :ctrl_c

        handle_event(event)
      end
    end
  end

  private

  def handle_event(event)
    return unless event.key?

    case event.code
    when "right"
      @ratio_index = (@ratio_index + 1) % @ratios.length
    when "left"
      @ratio_index = (@ratio_index - 1) % @ratios.length
    end
  end

  def draw
    current_ratio = @ratios[@ratio_index]

    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(1),
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.min(0)
      ],
      children: [
        RatatuiRuby::Paragraph.new(
          text: "LineGauge Widget Demo - Press ← → to cycle through ratios, 'q' to quit"
        ),
        # Static gauge at 20% with default block symbols
        RatatuiRuby::LineGauge.new(
          ratio: 0.2,
          label: "20%",
          filled_style: RatatuiRuby::Style.new(fg: :red),
          filled_symbol: "█",
          unfilled_symbol: "░",
          block: RatatuiRuby::Block.new(title: "Low Progress")
        ),
        # Static gauge at 50% with custom styled symbols
        RatatuiRuby::LineGauge.new(
          ratio: 0.5,
          label: "50%",
          filled_style: RatatuiRuby::Style.new(fg: :yellow),
          unfilled_style: RatatuiRuby::Style.new(fg: :dark_gray),
          filled_symbol: "=",
          unfilled_symbol: "-",
          block: RatatuiRuby::Block.new(title: "Medium Progress (custom symbols & styles)")
        ),
        # Static gauge at 80% with hash symbols and colored empty portion
        RatatuiRuby::LineGauge.new(
          ratio: 0.8,
          label: "80%",
          filled_style: RatatuiRuby::Style.new(fg: :green),
          unfilled_style: RatatuiRuby::Style.new(fg: :dark_gray),
          filled_symbol: "#",
          unfilled_symbol: "·",
          block: RatatuiRuby::Block.new(title: "High Progress (dual-colored)")
        ),
        # Interactive gauge with default symbols
        RatatuiRuby::LineGauge.new(
          ratio: current_ratio,
          label: "#{(current_ratio * 100).to_i}%",
          filled_style: RatatuiRuby::Style.new(fg: :cyan),
          filled_symbol: "█",
          unfilled_symbol: "░",
          block: RatatuiRuby::Block.new(title: "Interactive (use arrows)")
        ),
        # Status text
        RatatuiRuby::Paragraph.new(
          text: "Current ratio: #{@ratio_index + 1}/#{@ratios.length}"
        )
      ]
    )

    RatatuiRuby.draw(layout)
  end
end

LineGaugeDemoApp.new.run if __FILE__ == $PROGRAM_NAME
