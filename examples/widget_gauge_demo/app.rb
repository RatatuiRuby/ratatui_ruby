# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates completion visualization with interactive attribute cycling.
#
# Long-running tasks create anxiety. Users need to know that the system is working and how much is left to do.
#
# This demo showcases the <tt>Gauge</tt> widget. It provides an interactive playground where you can cycle through different ratios, colors, and label templates in real-time.
#
# Use it to understand how to communicate progress and task status in your terminal interface.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_gauge_demo/app.rb
#
# rdoc-image:/doc/images/widget_gauge_demo.png
class WidgetGaugeDemo
  def initialize
    @ratio = 0.65
    @ratios = [0.0, 0.25, 0.5, 0.65, 0.8, 0.95, 1.0]
    @ratio_index = 3

    @gauge_colors = [
      { name: "Green", color: :green },
      { name: "Yellow", color: :yellow },
      { name: "Red", color: :red },
      { name: "Cyan", color: :cyan },
      { name: "Blue", color: :blue },
    ]
    @gauge_color_index = 0

    @bg_styles = nil # Initialized in run when @tui is available
    @bg_style_index = 1

    @use_unicode_options = [true, false]
    @use_unicode_index = 0

    @label_modes = [
      { name: "Percentage", template: -> (ratio) { "#{(ratio * 100).to_i}%" } },
      { name: "Ratio (decimal)", template: -> (ratio) { format("%.2f", ratio) } },
      { name: "Progress", template: -> (ratio) { "Progress: #{(ratio * 100).to_i}%" } },
      { name: "None", template: -> (_ratio) { nil } },
    ]
    @label_mode_index = 0
    @hotkey_style = nil # Initialized in run when @tui is available
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui

      # Initialize styles using tui helpers
      @bg_styles = [
        { name: "None", style: nil },
        { name: "Dark Gray BG", style: tui.style(fg: :dark_gray) },
        { name: "White on Black", style: tui.style(fg: :white, bg: :black) },
        { name: "Bold White", style: tui.style(fg: :white, modifiers: [:bold]) },
      ]
      @hotkey_style = tui.style(modifiers: [:bold, :underlined])

      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    @ratio = @ratios[@ratio_index]
    gauge_color = @gauge_colors[@gauge_color_index][:color]
    bg_style = @bg_styles[@bg_style_index][:style]
    use_unicode = @use_unicode_options[@use_unicode_index]
    label_template = @label_modes[@label_mode_index][:template]

    gauge_style = @tui.style(fg: gauge_color)
    label = label_template.call(@ratio)

    @tui.draw do |frame|
      # Split into main content and control panel
      main_area, controls_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(6),
        ]
      )

      # Split main area into title, gauges, and spacer
      title_area, gauge1_area, gauge2_area, gauge3_area, spacer_area = @tui.layout_split(
        main_area,
        direction: :vertical,
        constraints: [
          @tui.constraint_length(1),
          @tui.constraint_fill(1),
          @tui.constraint_fill(1),
          @tui.constraint_fill(1),
          @tui.constraint_length(1),
        ]
      )

      # Render title
      title = @tui.paragraph(
        text: "Gauge Widget Demo",
        style: @tui.style(modifiers: [:bold])
      )
      frame.render_widget(title, title_area)

      # Gauge 1: Main interactive gauge
      gauge1 = @tui.gauge(
        ratio: @ratio,
        label:,
        style: bg_style,
        gauge_style:,
        use_unicode:,
        block: @tui.block(title: "Interactive Gauge")
      )
      frame.render_widget(gauge1, gauge1_area)

      # Gauge 2: Inverse ratio for comparison
      gauge2 = @tui.gauge(
        ratio: 1.0 - @ratio,
        label: label_template.call(1.0 - @ratio),
        style: bg_style,
        gauge_style:,
        use_unicode:,
        block: @tui.block(title: "Inverse (1.0 - ratio)")
      )
      frame.render_widget(gauge2, gauge2_area)

      # Gauge 3: Fixed at different stages
      gauge3 = @tui.gauge(
        ratio: [@ratio, 0.5].max,
        label: "Min 50%",
        style: @tui.style(fg: :dark_gray),
        gauge_style: @tui.style(fg: :magenta),
        use_unicode:,
        block: @tui.block(title: "Min Threshold (Magenta)")
      )
      frame.render_widget(gauge3, gauge3_area)

      # Render empty spacer
      spacer = @tui.paragraph(text: "")
      frame.render_widget(spacer, spacer_area)

      # Bottom controls panel
      controls = @tui.block(
        title: "Controls",
        borders: [:all],
        children: [
          @tui.paragraph(
            text: [
              # Navigation & General
              @tui.text_line(spans: [
                @tui.text_span(content: "←/→", style: @hotkey_style),
                @tui.text_span(content: ": Adjust Ratio (#{format('%.2f', @ratio)})  "),
                @tui.text_span(content: "q", style: @hotkey_style),
                @tui.text_span(content: ": Quit"),
              ]),
              # Styling
              @tui.text_line(spans: [
                @tui.text_span(content: "g", style: @hotkey_style),
                @tui.text_span(content: ": Color (#{@gauge_colors[@gauge_color_index][:name]})  "),
                @tui.text_span(content: "b", style: @hotkey_style),
                @tui.text_span(content: ": Background (#{@bg_styles[@bg_style_index][:name]})"),
              ]),
              # Options
              @tui.text_line(spans: [
                @tui.text_span(content: "u", style: @hotkey_style),
                @tui.text_span(content: ": Unicode (#{use_unicode ? 'On' : 'Off'})  "),
                @tui.text_span(content: "l", style: @hotkey_style),
                @tui.text_span(content: ": Label (#{@label_modes[@label_mode_index][:name]})"),
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
    in type: :key, code: "g"
      @gauge_color_index = (@gauge_color_index + 1) % @gauge_colors.length
    in type: :key, code: "b"
      @bg_style_index = (@bg_style_index + 1) % @bg_styles.length
    in type: :key, code: "u"
      @use_unicode_index = (@use_unicode_index + 1) % @use_unicode_options.length
    in type: :key, code: "l"
      @label_mode_index = (@label_mode_index + 1) % @label_modes.length
    else
      # Ignore other events
      nil
    end
  end
end

WidgetGaugeDemo.new.run if __FILE__ == $PROGRAM_NAME
