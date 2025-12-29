# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates LineGauge widget with interactive attribute cycling.
class LineGaugeDemoApp
  def initialize
    @ratio = 0.5
    @ratios = [0.2, 0.35, 0.5, 0.65, 0.8, 0.95]
    @ratio_index = 2

    @filled_symbols = [
      { name: "█ (Block)", symbol: "█" },
      { name: "▓ (Dark Shade)", symbol: "▓" },
      { name: "▒ (Medium Shade)", symbol: "▒" },
      { name: "= (Equals)", symbol: "=" },
      { name: "# (Hash)", symbol: "#" }
    ]
    @filled_symbol_index = 0

    @unfilled_symbols = [
      { name: "░ (Light Shade)", symbol: "░" },
      { name: "· (Dot)", symbol: "·" },
      { name: "- (Dash)", symbol: "-" },
      { name: "~ (Tilde)", symbol: "~" }
    ]
    @unfilled_symbol_index = 0

    @filled_colors = [
      { name: "Red", color: :red },
      { name: "Yellow", color: :yellow },
      { name: "Green", color: :green },
      { name: "Cyan", color: :cyan },
      { name: "Blue", color: :blue }
    ]
    @filled_color_index = 2

    @unfilled_colors = [
      { name: "Default", color: nil },
      { name: "Dark Gray", color: :dark_gray },
      { name: "Gray", color: :gray }
    ]
    @unfilled_color_index = 1

    @base_styles = [
      { name: "None", style: nil },
      { name: "Bold White", style: RatatuiRuby::Style.new(fg: :white, modifiers: [:bold]) },
      { name: "White on Blue", style: RatatuiRuby::Style.new(fg: :white, bg: :blue) },
      { name: "Italic Cyan", style: RatatuiRuby::Style.new(fg: :cyan, modifiers: [:italic]) }
    ]
    @base_style_index = 0
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    end
  end

  private

  def render
    @ratio = @ratios[@ratio_index]

    filled_color = @filled_colors[@filled_color_index][:color]
    unfilled_color = @unfilled_colors[@unfilled_color_index][:color]

    filled_style = filled_color ? RatatuiRuby::Style.new(fg: filled_color) : RatatuiRuby::Style.new(fg: :white)
    unfilled_style = unfilled_color ? RatatuiRuby::Style.new(fg: unfilled_color) : RatatuiRuby::Style.new(fg: :dark_gray)

    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.new(type: :percentage, value: 70),
        RatatuiRuby::Constraint.new(type: :percentage, value: 30)
      ],
      children: [
        # Main content area
        RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(1),
            RatatuiRuby::Constraint.length(4),
            RatatuiRuby::Constraint.length(4),
            RatatuiRuby::Constraint.fill(1)
          ],
          children: [
            RatatuiRuby::Paragraph.new(
              text: "LineGauge Widget Demo - Cycle attributes with hotkeys"
            ),
            # Example 1: Static gauge showing all features
            RatatuiRuby::LineGauge.new(
              ratio: @ratio,
              label: "#{(@ratio * 100).to_i}%",
              style: @base_styles[@base_style_index][:style],
              filled_style:,
              unfilled_style:,
              filled_symbol: @filled_symbols[@filled_symbol_index][:symbol],
              unfilled_symbol: @unfilled_symbols[@unfilled_symbol_index][:symbol],
              block: RatatuiRuby::Block.new(title: "Interactive Gauge")
            ),
            # Example 2: Inverted colors for contrast demonstration
            RatatuiRuby::LineGauge.new(
              ratio: 1.0 - @ratio,
              label: "#{((1.0 - @ratio) * 100).to_i}%",
              filled_style: RatatuiRuby::Style.new(fg: :black, bg: :yellow),
              unfilled_style: RatatuiRuby::Style.new(fg: :white, bg: :dark_gray),
              filled_symbol: @filled_symbols[@filled_symbol_index][:symbol],
              unfilled_symbol: @unfilled_symbols[@unfilled_symbol_index][:symbol],
              block: RatatuiRuby::Block.new(title: "Inverse (100% - ratio)")
            ),
            RatatuiRuby::Paragraph.new(text: "")
          ]
        ),
        # Sidebar with controls
        RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(7),
            RatatuiRuby::Constraint.length(7),
            RatatuiRuby::Constraint.length(6),
            RatatuiRuby::Constraint.fill(1)
          ],
          children: [
            # Ratio & Base Style
            RatatuiRuby::Block.new(
              title: "Ratio & Style",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: [
                    "←→: Ratio (#{(@ratio * 100).to_i}%)",
                    "b: Base Style",
                    "  #{@base_styles[@base_style_index][:name]}"
                  ]
                )
              ]
            ),
            # Filled Symbols & Colors
            RatatuiRuby::Block.new(
              title: "Filled",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: [
                    "f: Symbol",
                    "  #{@filled_symbols[@filled_symbol_index][:name]}",
                    "c: Color",
                    "  #{@filled_colors[@filled_color_index][:name]}"
                  ]
                )
              ]
            ),
            # Unfilled Symbols & Colors
            RatatuiRuby::Block.new(
              title: "Unfilled",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: [
                    "u: Symbol",
                    "  #{@unfilled_symbols[@unfilled_symbol_index][:name]}",
                    "x: Color",
                    "  #{@unfilled_colors[@unfilled_color_index][:name]}"
                  ]
                )
              ]
            ),
            # General
            RatatuiRuby::Block.new(
              title: "General",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: "q: Quit"
                )
              ]
            )
          ]
        )
      ]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "right"
      @ratio_index = (@ratio_index + 1) % @ratios.length
    in type: :key, code: "left"
      @ratio_index = (@ratio_index - 1) % @ratios.length
    in type: :key, code: "b"
      @base_style_index = (@base_style_index + 1) % @base_styles.length
    in type: :key, code: "f"
      @filled_symbol_index = (@filled_symbol_index + 1) % @filled_symbols.length
    in type: :key, code: "c"
      @filled_color_index = (@filled_color_index + 1) % @filled_colors.length
    in type: :key, code: "u"
      @unfilled_symbol_index = (@unfilled_symbol_index + 1) % @unfilled_symbols.length
    in type: :key, code: "x"
      @unfilled_color_index = (@unfilled_color_index + 1) % @unfilled_colors.length
    end
  end
end

LineGaugeDemoApp.new.run if __FILE__ == $PROGRAM_NAME
