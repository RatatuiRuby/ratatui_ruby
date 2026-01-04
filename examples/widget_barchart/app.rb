# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates categorical data visualization with interactive attribute cycling.
#
# Raw tables of numbers are hard to scan. Comparing magnitudes requires mental arithmetic, which slows down decision-making.
#
# This demo showcases the <tt>BarChart</tt> widget. It provides an interactive playground where you can cycle through different data formats, styles, and orientations in real-time.
#
# Use it to understand how to visualize and compare discrete datasets effectively.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_barchart/app.rb
#
# rdoc-image:/doc/images/widget_barchart.png
class WidgetBarchart
  def initialize
    @data_index = 2
    @styles = nil # Initialized in run
    @style_index = 3
    @label_style_index = 3
    @value_style_index = 3
    @bar_sets = [
      { name: "Default", set: nil },
      { name: "Numbers (Short)", set: { 8 => "8", 7 => "7", 6 => "6", 5 => "5", 4 => "4", 3 => "3", 2 => "2", 1 => "1", 0 => "0" } },
      { name: "Letters (Long)", set: { full: "H", seven_eighths: "G", three_quarters: "F", five_eighths: "E", half: "D", three_eighths: "C", one_quarter: "B", one_eighth: "A", empty: " " } },
      { name: "ASCII (Heights)", set: [" ", "_", ".", "-", "=", "+", "*", "#", "@"] },
    ]
    @bar_set_index = 0
    @direction = :vertical
    @bar_width = 8
    @bar_gap = 1
    @group_gap = 2
    @height_mode = :full
    @hotkey_style = nil
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      init_styles

      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def init_styles
    @styles = [
      { name: "Green", style: @tui.style(fg: :green) },
      { name: "Blue", style: @tui.style(fg: :blue) },
      { name: "Red", style: @tui.style(fg: :red) },
      { name: "Cyan", style: @tui.style(fg: :cyan) },
      { name: "Yellow Bold", style: @tui.style(fg: :yellow, modifiers: [:bold]) },
      { name: "Reversed", style: @tui.style(modifiers: [:reversed]) },
    ]
    @hotkey_style = @tui.style(modifiers: [:bold, :underlined])
  end

  private def current_data
    case @data_index
    when 0 # Simple Hash
      {
        "Q1" => 50,
        "Q2" => 80,
        "Q3" => 45,
        "Q4" => 60,
        "Q1'" => 55,
        "Q2'" => 85,
        "Q3'" => 50,
        "Q4'" => 65,
      }
    when 1 # Array with styles
      [
        ["Mon", 120],
        ["Tue", 150],
        ["Wed", 130],
        ["Thu", 160],
        ["Fri", 140],
        ["Sat", 110, @tui.style(fg: :red)],
        ["Sun", 100, @tui.style(fg: :red)],
      ]
    when 2 # Groups
      [
        @tui.bar_chart_bar_group(label: "2024", bars: [
          @tui.bar_chart_bar(value: 40, label: "Q1"),
          @tui.bar_chart_bar(value: 45, label: "Q2"),
          @tui.bar_chart_bar(value: 50, label: "Q3"),
          @tui.bar_chart_bar(value: 55, label: "Q4"),
        ]),
        @tui.bar_chart_bar_group(label: "2025", bars: [
          @tui.bar_chart_bar(value: 60, label: "Q1", style: @tui.style(fg: :yellow)),
          @tui.bar_chart_bar(value: 65, label: "Q2", style: @tui.style(fg: :yellow)),
          @tui.bar_chart_bar(value: 70, label: "Q3", style: @tui.style(fg: :yellow)),
          @tui.bar_chart_bar(value: 75, label: "Q4", style: @tui.style(fg: :yellow)),
        ]),
      ]
    end
  end

  private def data_name
    ["Simple Hash", "Styled Array", "Groups"][@data_index]
  end

  private def render
    @tui.draw do |frame|
      chart_area, controls_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(6),
        ]
      )

      # Handle Mini Mode
      effective_chart_area = if @height_mode == :mini
        mini_area, = @tui.layout_split(
          chart_area,
          direction: :vertical,
          constraints: [
            @tui.constraint_length(3),
            @tui.constraint_fill(1),
          ]
        )
        mini_area
      else
        chart_area
      end

      bar_chart = @tui.bar_chart(
        data: current_data,
        bar_width: @bar_width,
        style: @styles[@style_index][:style],
        bar_gap: @bar_gap,
        group_gap: @group_gap,
        direction: @direction,
        label_style: @styles[@label_style_index][:style],
        value_style: @styles[@value_style_index][:style],
        bar_set: @bar_sets[@bar_set_index][:set],
        block: @tui.block(
          title: "BarChart: #{data_name}",
          borders: [:all]
        )
      )
      frame.render_widget(bar_chart, effective_chart_area)

      render_controls(frame, controls_area)
    end
  end

  private def render_controls(frame, area)
    controls = @tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        @tui.paragraph(
          text: [
            @tui.text_line(spans: [
              @tui.text_span(content: "d", style: @hotkey_style),
              @tui.text_span(content: ": Data (#{data_name})  "),
              @tui.text_span(content: "v", style: @hotkey_style),
              @tui.text_span(content: ": Direction (#{@direction})  "),
              @tui.text_span(content: "q", style: @hotkey_style),
              @tui.text_span(content: ": Quit"),
            ]),
            @tui.text_line(spans: [
              @tui.text_span(content: "w", style: @hotkey_style),
              @tui.text_span(content: ": Width (#{@bar_width})  "),
              @tui.text_span(content: "a", style: @hotkey_style),
              @tui.text_span(content: ": Gap (#{@bar_gap})  "),
              @tui.text_span(content: "g", style: @hotkey_style),
              @tui.text_span(content: ": Group Gap (#{@group_gap})"),
            ]),
            @tui.text_line(spans: [
              @tui.text_span(content: "s", style: @hotkey_style),
              @tui.text_span(content: ": Style (#{@styles[@style_index][:name]})  "),
              @tui.text_span(content: "x", style: @hotkey_style),
              @tui.text_span(content: ": Label (#{@styles[@label_style_index][:name]})  "),
              @tui.text_span(content: "z", style: @hotkey_style),
              @tui.text_span(content: ": Value (#{@styles[@value_style_index][:name]})  "),
            ]),
            @tui.text_line(spans: [
              @tui.text_span(content: "b", style: @hotkey_style),
              @tui.text_span(content: ": Set (#{@bar_sets[@bar_set_index][:name]})  "),
              @tui.text_span(content: "m", style: @hotkey_style),
              @tui.text_span(content: ": Mode (#{(@height_mode == :full) ? 'Full' : 'Mini'})"),
            ]),
          ]
        ),
      ]
    )
    frame.render_widget(controls, area)
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "d"
      @data_index = (@data_index + 1) % 3
    in type: :key, code: "v"
      @direction = (@direction == :vertical) ? :horizontal : :vertical
      # Adjust width default based on direction for better UX, though user can manually adjust 'w'
      @bar_width = (@direction == :vertical) ? 8 : 1
    in type: :key, code: "w"
      @bar_width = (@bar_width % 10) + 1
    in type: :key, code: "a"
      @bar_gap = (@bar_gap + 1) % 5
    in type: :key, code: "g"
      @group_gap = (@group_gap + 1) % 5
    in type: :key, code: "s"
      @style_index = (@style_index + 1) % @styles.size
    in type: :key, code: "x"
      @label_style_index = (@label_style_index + 1) % @styles.size
    in type: :key, code: "z"
      @value_style_index = (@value_style_index + 1) % @styles.size
    in type: :key, code: "b"
      @bar_set_index = (@bar_set_index + 1) % @bar_sets.size
    in type: :key, code: "m"
      @height_mode = (@height_mode == :full) ? :mini : :full
    else
      # Ignore
    end
  end
end

WidgetBarchart.new.run if __FILE__ == $0
