# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates high-density data visualization with interactive attribute cycling.
#
# Users need context. A single value ("90% CPU") tells you current status, but not the trend. Full charts take up too much room.
#
# This demo showcases the <tt>Sparkline</tt> widget. It provides an interactive playground where you can cycle through data sets, directions, colors, and custom bar sets.
#
# Use it to understand how to condense history into a single line for dashboards or headers.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_sparkline_demo/app.rb
#
# rdoc-image:/doc/images/widget_sparkline_demo.png
class WidgetSparklineDemo
  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      setup
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def setup
    # Data sets with different characteristics
    @data_sets = [
      {
        name: "Steady Growth",
        data: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
      },
      {
        name: "With Gaps",
        data: [5, nil, 8, nil, 6, nil, 9, nil, 7, nil, 10, nil],
      },
      {
        name: "Random",
        data: [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8],
      },
      {
        name: "Sawtooth",
        data: [1, 2, 3, 4, 5, 4, 3, 2, 1, 2, 3, 4],
      },
      {
        name: "Peaks",
        data: [1, 5, 1, 8, 1, 6, 1, 9, 1, 7, 1, 10],
      },
    ]
    @data_index = 2
    srand(12345) # Ensure reproducible "Random" data for snapshots

    @directions = [
      { name: "Left to Right", direction: :left_to_right },
      { name: "Right to Left", direction: :right_to_left },
    ]
    @direction_index = 0

    @styles = [
      { name: "Green", style: @tui.style(fg: :green) },
      { name: "Yellow", style: @tui.style(fg: :yellow) },
      { name: "Red", style: @tui.style(fg: :red) },
      { name: "Cyan", style: @tui.style(fg: :cyan) },
      { name: "Magenta", style: @tui.style(fg: :magenta) },
    ]
    @style_index = 3

    @absent_symbols = [
      { name: "None", symbol: nil },
      { name: "Dot (·)", symbol: "·" },
      { name: "Square (▫)", symbol: "▫" },
      { name: "Dash (-)", symbol: "-" },
      { name: "Underscore (_)", symbol: "_" },
    ]
    @absent_symbol_index = 1

    @absent_styles = [
      { name: "Default", style: nil },
      { name: "Dark Gray", style: @tui.style(fg: :dark_gray) },
      { name: "Dim Red", style: @tui.style(fg: :red, modifiers: [:dim]) },
      { name: "Dim Yellow", style: @tui.style(fg: :yellow, modifiers: [:dim]) },
    ]
    @absent_style_index = 2

    @bar_sets = [
      { name: "Default (Block)", set: nil },
      {
        name: "Numbers (0-8)",
        set: {
          0 => "0", 1 => "1", 2 => "2", 3 => "3", 4 => "4", 5 => "5", 6 => "6", 7 => "7", 8 => "8"
        },
      },
      { name: "ASCII (Heights)", set: [" ", "_", ".", "-", "=", "+", "*", "#", "@"] },
    ]
    @bar_set_index = 0

    @hotkey_style = @tui.style(modifiers: [:bold, :underlined])
  end

  private def render
    @tui.draw do |frame|
      data_set = @data_sets[@data_index]
      direction = @directions[@direction_index][:direction]
      style = @styles[@style_index][:style]
      absent_symbol = @absent_symbols[@absent_symbol_index][:symbol]
      absent_value_style = @absent_styles[@absent_style_index][:style]
      bar_set = @bar_sets[@bar_set_index][:set]

      # Use static data for clarity when cycling options
      current_data = data_set[:data]

      layout = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(6),
        ]
      )

      # Main content area with multiple sparkline examples
      main_content_area = layout[0]
      main_layout = @tui.layout_split(
        main_content_area,
        direction: :vertical,
        constraints: [
          @tui.constraint_length(1),
          @tui.constraint_length(3),
          @tui.constraint_length(3),
          @tui.constraint_length(3),
          @tui.constraint_length(3),
          @tui.constraint_fill(1),
        ]
      )

      frame.render_widget(
        @tui.paragraph(text: "Sparkline Widget Demo - Cycle attributes with hotkeys"),
        main_layout[0]
      )

      # Sparkline 1: Main interactive sparkline
      frame.render_widget(
        @tui.sparkline(
          data: current_data,
          direction:,
          style:,
          absent_value_symbol: absent_symbol,
          absent_value_style:,
          bar_set:,
          block: @tui.block(title: "Interactive Sparkline")
        ),
        main_layout[1]
      )

      # Sparkline 2: Same data, opposite direction
      frame.render_widget(
        @tui.sparkline(
          data: current_data.reverse,
          direction:,
          style:,
          absent_value_symbol: absent_symbol,
          absent_value_style:,
          bar_set:,
          block: @tui.block(title: "Reversed Data")
        ),
        main_layout[2]
      )

      # Sparkline 3: Without absent value symbol (for comparison)
      frame.render_widget(
        @tui.sparkline(
          data: current_data,
          direction:,
          style:,
          bar_set:,
          block: @tui.block(title: "Without Absent Marker")
        ),
        main_layout[3]
      )

      # Sparkline 4: Gap pattern responsive to absent marker controls
      frame.render_widget(
        @tui.sparkline(
          data: [5, nil, 8, nil, 6, nil, 9, nil, 7, nil, 10, nil],
          direction:,
          style: @tui.style(fg: :blue),
          absent_value_symbol: absent_symbol,
          absent_value_style:,
          bar_set:,
          block: @tui.block(title: "Gap Pattern (Responsive)")
        ),
        main_layout[4]
      )

      # Bottom control panel
      control_area = layout[1]
      frame.render_widget(
        @tui.block(
          title: "Controls",
          borders: [:all],
          children: [
            @tui.paragraph(
              text: [
                # Line 1: Data
                @tui.text_line(spans: [
                  @tui.text_span(content: "↑/↓", style: @hotkey_style),
                  @tui.text_span(content: ": Data (#{@data_sets[@data_index][:name]})"),
                ]),
                # Line 2: View
                @tui.text_line(spans: [
                  @tui.text_span(content: "d", style: @hotkey_style),
                  @tui.text_span(content: ": Direction (#{@directions[@direction_index][:name]})  "),
                  @tui.text_span(content: "c", style: @hotkey_style),
                  @tui.text_span(content: ": Color (#{@styles[@style_index][:name]})"),
                ]),
                # Line 3: Markers
                @tui.text_line(spans: [
                  @tui.text_span(content: "m", style: @hotkey_style),
                  @tui.text_span(content: ": Absent Value Symbol (#{@absent_symbols[@absent_symbol_index][:name]})  "),
                  @tui.text_span(content: "s", style: @hotkey_style),
                  @tui.text_span(content: ": Absent Value Style (#{@absent_styles[@absent_style_index][:name]})"),
                ]),
                # Line 4: General
                @tui.text_line(spans: [
                  @tui.text_span(content: "b", style: @hotkey_style),
                  @tui.text_span(content: ": Bar Set (#{@bar_sets[@bar_set_index][:name]})  "),
                  @tui.text_span(content: "q", style: @hotkey_style),
                  @tui.text_span(content: ": Quit"),
                ]),
              ]
            ),
          ]
        ),
        control_area
      )
    end
  end

  private def handle_input
    event = @tui.poll_event

    case event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "up"
      @data_index = (@data_index - 1) % @data_sets.length
    in type: :key, code: "down"
      @data_index = (@data_index + 1) % @data_sets.length
    in type: :key, code: "d"
      @direction_index = (@direction_index + 1) % @directions.length
    in type: :key, code: "c"
      @style_index = (@style_index + 1) % @styles.length
    in type: :key, code: "m"
      @absent_symbol_index = (@absent_symbol_index + 1) % @absent_symbols.length
    in type: :key, code: "s"
      @absent_style_index = (@absent_style_index + 1) % @absent_styles.length
    in type: :key, code: "b"
      @bar_set_index = (@bar_set_index + 1) % @bar_sets.length
    else
      nil
    end
  end
end

WidgetSparklineDemo.new.run if __FILE__ == $PROGRAM_NAME
