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
      { name: "# (Hash)", symbol: "#" },
    ]
    @filled_symbol_index = 0

    @unfilled_symbols = [
      { name: "░ (Light Shade)", symbol: "░" },
      { name: "· (Dot)", symbol: "·" },
      { name: "- (Dash)", symbol: "-" },
      { name: "~ (Tilde)", symbol: "~" },
    ]
    @unfilled_symbol_index = 0

    @filled_colors = [
      { name: "Red", color: :red },
      { name: "Yellow", color: :yellow },
      { name: "Green", color: :green },
      { name: "Cyan", color: :cyan },
      { name: "Blue", color: :blue },
    ]
    @filled_color_index = 2

    @unfilled_colors = [
      { name: "Default", color: nil },
      { name: "Dark Gray", color: :dark_gray },
      { name: "Gray", color: :gray },
    ]
    @unfilled_color_index = 1

    @base_styles = nil # Initialized in run when @tui is available
    @base_style_index = 0
    @hotkey_style = nil # Initialized in run when @tui is available
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui

      # Initialize styles using tui helpers
      @base_styles = [
        { name: "None", style: nil },
        { name: "Bold White", style: tui.style(fg: :white, modifiers: [:bold]) },
        { name: "White on Blue", style: tui.style(fg: :white, bg: :blue) },
        { name: "Italic Cyan", style: tui.style(fg: :cyan, modifiers: [:italic]) },
      ]
      @hotkey_style = tui.style(modifiers: [:bold, :underlined])

      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    end
  end

  private def render
    @ratio = @ratios[@ratio_index]

    filled_color = @filled_colors[@filled_color_index][:color]
    unfilled_color = @unfilled_colors[@unfilled_color_index][:color]

    filled_style = filled_color ? @tui.style(fg: filled_color) : @tui.style(fg: :white)
    unfilled_style = unfilled_color ? @tui.style(fg: unfilled_color) : @tui.style(fg: :dark_gray)

    @tui.draw do |frame|
      # Split into main content and control panel
      main_area, controls_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(5),
        ]
      )

      # Split main area into title, gauges, and spacer
      title_area, gauge1_area, gauge2_area, spacer_area = @tui.layout_split(
        main_area,
        direction: :vertical,
        constraints: [
          @tui.constraint_length(1),
          @tui.constraint_length(4),
          @tui.constraint_length(4),
          @tui.constraint_fill(1),
        ]
      )

      # Render title
      title = @tui.paragraph(text: "LineGauge Widget Demo - Cycle attributes with hotkeys")
      frame.render_widget(title, title_area)

      # Example 1: Static gauge showing all features
      gauge1 = @tui.line_gauge(
        ratio: @ratio,
        label: "#{(@ratio * 100).to_i}%",
        style: @base_styles[@base_style_index][:style],
        filled_style:,
        unfilled_style:,
        filled_symbol: @filled_symbols[@filled_symbol_index][:symbol],
        unfilled_symbol: @unfilled_symbols[@unfilled_symbol_index][:symbol],
        block: @tui.block(title: "Interactive Gauge")
      )
      frame.render_widget(gauge1, gauge1_area)

      # Example 2: Inverted colors for contrast demonstration
      gauge2 = @tui.line_gauge(
        ratio: 1.0 - @ratio,
        label: "#{((1.0 - @ratio) * 100).to_i}%",
        filled_style: @tui.style(fg: :black, bg: :yellow),
        unfilled_style: @tui.style(fg: :white, bg: :dark_gray),
        filled_symbol: @filled_symbols[@filled_symbol_index][:symbol],
        unfilled_symbol: @unfilled_symbols[@unfilled_symbol_index][:symbol],
        block: @tui.block(title: "Inverse (100% - ratio)")
      )
      frame.render_widget(gauge2, gauge2_area)

      # Render empty spacer
      spacer = @tui.paragraph(text: "")
      frame.render_widget(spacer, spacer_area)

      # Bottom control panel
      controls = @tui.block(
        title: "Controls",
        borders: [:all],
        children: [
          @tui.paragraph(
            text: [
              # Line 1: General
              @tui.text_line(spans: [
                @tui.text_span(content: "←/→", style: @hotkey_style),
                @tui.text_span(content: ": Ratio (#{(@ratio * 100).to_i}%)  "),
                @tui.text_span(content: "b", style: @hotkey_style),
                @tui.text_span(content: ": Base Style (#{@base_styles[@base_style_index][:name]})  "),
                @tui.text_span(content: "q", style: @hotkey_style),
                @tui.text_span(content: ": Quit"),
              ]),
              # Line 2: Filled
              @tui.text_line(spans: [
                @tui.text_span(content: "f", style: @hotkey_style),
                @tui.text_span(content: ": Filled Symbol (#{@filled_symbols[@filled_symbol_index][:name]})  "),
                @tui.text_span(content: "c", style: @hotkey_style),
                @tui.text_span(content: ": Filled Color (#{@filled_colors[@filled_color_index][:name]})"),
              ]),
              # Line 3: Unfilled
              @tui.text_line(spans: [
                @tui.text_span(content: "u", style: @hotkey_style),
                @tui.text_span(content: ": Unfilled Symbol (#{@unfilled_symbols[@unfilled_symbol_index][:name]})  "),
                @tui.text_span(content: "x", style: @hotkey_style),
                @tui.text_span(content: ": Unfilled Color (#{@unfilled_colors[@unfilled_color_index][:name]})"),
              ]),
            ]
          ),
        ]
      )
      frame.render_widget(controls, controls_area)
    end
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
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
    else
      # Ignore other events
      nil
    end
  end
end

LineGaugeDemoApp.new.run if __FILE__ == $PROGRAM_NAME
