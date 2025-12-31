# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates Sparkline widget with interactive attribute cycling.
class SparklineDemoApp
  def initialize
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
    @data_index = 0

    @directions = [
      { name: "Left to Right", direction: :left_to_right },
      { name: "Right to Left", direction: :right_to_left },
    ]
    @direction_index = 0

    @styles = [
      { name: "Green", style: RatatuiRuby::Style.new(fg: :green) },
      { name: "Yellow", style: RatatuiRuby::Style.new(fg: :yellow) },
      { name: "Red", style: RatatuiRuby::Style.new(fg: :red) },
      { name: "Cyan", style: RatatuiRuby::Style.new(fg: :cyan) },
      { name: "Magenta", style: RatatuiRuby::Style.new(fg: :magenta) },
    ]
    @style_index = 0

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
      { name: "Dark Gray", style: RatatuiRuby::Style.new(fg: :dark_gray) },
      { name: "Dim Red", style: RatatuiRuby::Style.new(fg: :red, modifiers: [:dim]) },
      { name: "Dim Yellow", style: RatatuiRuby::Style.new(fg: :yellow, modifiers: [:dim]) },
    ]
    @absent_style_index = 0

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

    @counter = 0
    @hotkey_style = RatatuiRuby::Style.new(modifiers: [:bold, :underlined])
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    @counter += 1

    data_set = @data_sets[@data_index]
    direction = @directions[@direction_index][:direction]
    style = @styles[@style_index][:style]
    absent_symbol = @absent_symbols[@absent_symbol_index][:symbol]
    absent_value_style = @absent_styles[@absent_style_index][:style]
    bar_set = @bar_sets[@bar_set_index][:set]

    # Use static data for clarity when cycling options
    current_data = data_set[:data]

    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(6),
      ],
      children: [
        # Main content area with multiple sparkline examples
        RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(1),
            RatatuiRuby::Constraint.length(3),
            RatatuiRuby::Constraint.length(3),
            RatatuiRuby::Constraint.length(3),
            RatatuiRuby::Constraint.length(3),
            RatatuiRuby::Constraint.fill(1),
          ],
          children: [
            RatatuiRuby::Paragraph.new(
              text: "Sparkline Widget Demo - Cycle attributes with hotkeys"
            ),
            # Sparkline 1: Main interactive sparkline
            RatatuiRuby::Sparkline.new(
              data: current_data,
              direction:,
              style:,
              absent_value_symbol: absent_symbol,
              absent_value_style:,
              bar_set:,
              block: RatatuiRuby::Block.new(title: "Interactive Sparkline")
            ),
            # Sparkline 2: Same data, opposite direction
            RatatuiRuby::Sparkline.new(
              data: current_data.reverse,
              direction:,
              style:,
              absent_value_symbol: absent_symbol,
              absent_value_style:,
              bar_set:,
              block: RatatuiRuby::Block.new(title: "Reversed Data")
            ),
            # Sparkline 3: Without absent value symbol (for comparison)
            RatatuiRuby::Sparkline.new(
              data: current_data,
              direction:,
              style:,
              bar_set:,
              block: RatatuiRuby::Block.new(title: "Without Absent Marker")
            ),
            # Sparkline 4: Gap pattern responsive to absent marker controls
            RatatuiRuby::Sparkline.new(
              data: [5, nil, 8, nil, 6, nil, 9, nil, 7, nil, 10, nil],
              direction:,
              style: RatatuiRuby::Style.new(fg: :blue),
              absent_value_symbol: absent_symbol,
              absent_value_style:,
              bar_set:,
              block: RatatuiRuby::Block.new(title: "Gap Pattern (Responsive)")
            ),
            RatatuiRuby::Paragraph.new(text: ""),
          ]
        ),
        # Bottom control panel
        RatatuiRuby::Block.new(
          title: "Controls",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                # Line 1: Data
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "↑/↓", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Data (#{@data_sets[@data_index][:name]})"),
                ]),
                # Line 2: View
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "d", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Direction (#{@directions[@direction_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "c", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Color (#{@styles[@style_index][:name]})"),
                ]),
                # Line 3: Markers
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "m", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Absent Value Symbol (#{@absent_symbols[@absent_symbol_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "s", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Absent Value Style (#{@absent_styles[@absent_style_index][:name]})"),
                ]),
                # Line 4: General
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "b", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Bar Set (#{@bar_sets[@bar_set_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Quit"),
                ]),
              ]
            ),
          ]
        ),
      ]
    )

    RatatuiRuby.draw(layout)
  end

  private def handle_input
    event = RatatuiRuby.poll_event
    return unless event

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

SparklineDemoApp.new.run if __FILE__ == $PROGRAM_NAME
