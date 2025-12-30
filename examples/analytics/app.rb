# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Analytics Dashboard Example
# Demonstrates Tabs and BarChart widgets.

class AnalyticsApp
  def initialize
    @selected_tab = 0
    @tabs = ["Revenue", "Traffic", "Errors"]
    @styles = [
      { name: "Yellow Bold", style: RatatuiRuby::Style.new(fg: :yellow, modifiers: [:bold]) },
      { name: "Italic Blue on White", style: RatatuiRuby::Style.new(fg: :blue, bg: :white, modifiers: [:italic]) },
      { name: "Underlined Red", style: RatatuiRuby::Style.new(fg: :red, modifiers: [:underlined]) },
      { name: "Reversed", style: RatatuiRuby::Style.new(modifiers: [:reversed]) }
    ]
    @style_index = 0
    @divider_index = 0
    @dividers = [" | ", " • ", " > ", " / "]
    @base_styles = [
      { name: "Default", style: nil },
      { name: "White on Gray", style: RatatuiRuby::Style.new(fg: :white, bg: :dark_gray) },
      { name: "White on Blue", style: RatatuiRuby::Style.new(fg: :white, bg: :blue) },
      { name: "Italic", style: RatatuiRuby::Style.new(modifiers: [:italic]) }
    ]
    @base_style_index = 0
    @padding_left = 0
    @padding_right = 0
    @direction = :vertical
    @label_style_index = 0
    @value_style_index = 0
    @bar_sets = [
      { name: "Default", set: nil },
      { name: "Numbers (Short)", set: { 8 => "8", 7 => "7", 6 => "6", 5 => "5", 4 => "4", 3 => "3", 2 => "2", 1 => "1", 0 => "0" } },
      { name: "Letters (Long)", set: { full: "H", seven_eighths: "G", three_quarters: "F", five_eighths: "E", half: "D", three_eighths: "C", one_quarter: "B", one_eighth: "A", empty: " " } },
      { name: "ASCII (Array)", set: [" ", ".", ":", "-", "+", "*", "#", "%", "@"] }
    ]
    @bar_set_index = 0
    @height_mode = :full # :full or :mini

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

  private

  def render
    # Data for different tabs
    data = case @selected_tab
           when 0 # Revenue
             { "Q1" => 50, "Q2" => 80 }
           when 1 # Traffic
             { "Mon" => 120, "Tue" => 150 }
           when 2 # Errors
             { "DB" => 5, "UI" => 2 }
    end

    bar_style = case @selected_tab
                when 0 then RatatuiRuby::Style.new(fg: "green")
                when 1 then RatatuiRuby::Style.new(fg: "blue")
                when 2 then RatatuiRuby::Style.new(fg: "red")
    end

    # Define the BarChart widget
    bar_chart = RatatuiRuby::BarChart.new(
      data:,
      bar_width: @direction == :vertical ? 8 : 1,
      style: bar_style,
      direction: @direction,
      label_style: @styles[@label_style_index][:style],
      value_style: @styles[@value_style_index][:style],
      bar_set: @bar_sets[@bar_set_index][:set],
      block: RatatuiRuby::Block.new(
        title: "Analytics: #{@tabs[@selected_tab]}",
        borders: [:all]
      )
    )

    # Wrap chart in a layout to control height if in mini mode
    chart_area = if @height_mode == :mini
       # Height 3: 1 row content + 2 borders
       RatatuiRuby::Layout.new(
         direction: :vertical,
         constraints: [RatatuiRuby::Constraint.length(3), RatatuiRuby::Constraint.fill(1)],
         children: [bar_chart, RatatuiRuby::Block.new] # Empty block to fill rest
       )
    else
      bar_chart
    end

    # Build the UI
    ui = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(6),
      ],
      children: [
        # Main Area
        RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.new(type: :length, value: 3),
            RatatuiRuby::Constraint.new(type: :min, value: 0),
          ],
          children: [
            RatatuiRuby::Tabs.new(
              titles: @tabs,
              selected_index: @selected_tab,
              block: RatatuiRuby::Block.new(title: "Views", borders: [:all]),
              divider: @dividers[@divider_index],
              highlight_style: @styles[@style_index][:style],
              style: @base_styles[@base_style_index][:style],
              padding_left: @padding_left,
              padding_right: @padding_right
            ),
            chart_area
          ]
        ),
        # Bottom control panel
        RatatuiRuby::Block.new(
          title: "Controls",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                # Line 1: Navigation & General
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "←/→", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Navigate Tab  "),
                  RatatuiRuby::Text::Span.new(content: "v", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Direction (#{@direction})  "),
                  RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Quit")
                ]),
                # Line 2: Padding & Divider
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "h/l", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Pad Left (#{@padding_left})  "),
                  RatatuiRuby::Text::Span.new(content: "j/k", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Pad Right (#{@padding_right})  "),
                  RatatuiRuby::Text::Span.new(content: "d", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Divider (#{@dividers[@divider_index]})")
                ]),
                # Line 3: Styles
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "space", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Highlight (#{@styles[@style_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "x", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Label (#{@styles[@label_style_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "space", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Highlight (#{@styles[@style_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "x", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Label (#{@styles[@label_style_index][:name]})")
                ]),
                # Line 4: More Styles
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "z", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Value (#{@styles[@value_style_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "b", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Bar Set (#{@bar_sets[@bar_set_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "m", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Mode (#{@height_mode == :full ? 'Full' : 'Mini'})")
                ])
              ]
            )
          ]
        )
      ]
    )

    RatatuiRuby.draw(ui)
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "right"
      @selected_tab = (@selected_tab + 1) % @tabs.size
    in type: :key, code: "left"
      @selected_tab = (@selected_tab - 1) % @tabs.size
    in type: :key, code: " "
      @style_index = (@style_index + 1) % @styles.size
    in type: :key, code: "d"
      @divider_index = (@divider_index + 1) % @dividers.size
    in type: :key, code: "s"
      @base_style_index = (@base_style_index + 1) % @base_styles.size
    in type: :key, code: "h"
      @padding_left = [@padding_left - 1, 0].max
    in type: :key, code: "l"
      @padding_left += 1
    in type: :key, code: "v"
      @direction = @direction == :vertical ? :horizontal : :vertical
    in type: :key, code: "j"
      @padding_right = [@padding_right - 1, 0].max
    in type: :key, code: "k"
      @padding_right += 1
    in type: :key, code: "x"
      @label_style_index = (@label_style_index + 1) % @styles.size
    in type: :key, code: "z"
      @value_style_index = (@value_style_index + 1) % @styles.size
    in type: :key, code: "b"
      @bar_set_index = (@bar_set_index + 1) % @bar_sets.size
    in type: :key, code: "m"
      @height_mode = @height_mode == :full ? :mini : :full
    else
      # Ignore other events
    end
  end
end

AnalyticsApp.new.run if __FILE__ == $0
