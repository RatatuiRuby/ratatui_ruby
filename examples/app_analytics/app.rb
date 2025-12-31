# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Analytics Dashboard Example
# Demonstrates Tabs and BarChart widgets using the Session API.

class AppAnalytics
  def initialize
    @selected_tab = 0
    @tabs = ["Revenue", "Traffic", "Errors", "Quarterly"]
    @styles = nil # Initialized in run when tui is available
    @style_index = 0
    @divider_index = 0
    @dividers = [" | ", " • ", " > ", " / "]
    @base_styles = nil # Initialized in run when tui is available
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
      { name: "ASCII (Heights)", set: [" ", "_", ".", "-", "=", "+", "*", "#", "@"] },
    ]
    @bar_set_index = 0
    @height_mode = :full # :full or :mini
    @group_gap = 0
    @hotkey_style = nil # Initialized in run when tui is available
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui

      # Initialize styles using tui helpers
      @styles = [
        { name: "Yellow Bold", style: tui.style(fg: :yellow, modifiers: [:bold]) },
        { name: "Italic Blue on White", style: tui.style(fg: :blue, bg: :white, modifiers: [:italic]) },
        { name: "Underlined Red", style: tui.style(fg: :red, modifiers: [:underlined]) },
        { name: "Reversed", style: tui.style(modifiers: [:reversed]) },
      ]
      @base_styles = [
        { name: "Default", style: nil },
        { name: "White on Gray", style: tui.style(fg: :white, bg: :dark_gray) },
        { name: "White on Blue", style: tui.style(fg: :white, bg: :blue) },
        { name: "Italic", style: tui.style(modifiers: [:italic]) },
      ]
      @hotkey_style = tui.style(modifiers: [:bold, :underlined])

      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
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

      # Split main area into tabs and chart
      tabs_area, chart_area = @tui.layout_split(
        main_area,
        direction: :vertical,
        constraints: [
          @tui.constraint_length(3),
          @tui.constraint_min(0),
        ]
      )

      # Render tabs widget
      tabs = @tui.tabs(
        titles: @tabs,
        selected_index: @selected_tab,
        block: @tui.block(title: "Views", borders: [:all]),
        divider: @dividers[@divider_index],
        highlight_style: @styles[@style_index][:style],
        style: @base_styles[@base_style_index][:style],
        padding_left: @padding_left,
        padding_right: @padding_right
      )
      frame.render_widget(tabs, tabs_area)

      # Data for different tabs
      data = case @selected_tab
             when 0 # Revenue
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
             when 1 # Traffic
               [
                 ["Mon", 120],
                 ["Tue", 150],
                 ["Wed", 130],
                 ["Thu", 160],
                 ["Fri", 140],
                 ["Sat", 110, @tui.style(fg: :red)],
                 ["Sun", 100, @tui.style(fg: :red)],
               ]
             when 2 # Errors
               { DB: 5, UI: 2, API: 8, Auth: 3, Net: 4, "I/O": 1, Mem: 6, CPU: 7 }
             when 3 # Quarterly
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

      bar_style = case @selected_tab
                  when 0 then @tui.style(fg: "green")
                  when 1 then @tui.style(fg: "blue")
                  when 2 then @tui.style(fg: "red")
                  when 3 then @tui.style(fg: "cyan")
      end

      # Determine effective chart area for mini mode
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

      # Define and render the BarChart widget
      bar_chart = @tui.bar_chart(
        data:,
        bar_width: (@direction == :vertical) ? 8 : 1,
        style: bar_style,
        bar_gap: 1,
        group_gap: @group_gap,
        direction: @direction,
        label_style: @styles[@label_style_index][:style],
        value_style: @styles[@value_style_index][:style],
        bar_set: @bar_sets[@bar_set_index][:set],
        block: @tui.block(
          title: "Analytics: #{@tabs[@selected_tab]}",
          borders: [:all]
        )
      )
      frame.render_widget(bar_chart, effective_chart_area)

      # Render controls panel
      controls = @tui.block(
        title: "Controls",
        borders: [:all],
        children: [
          @tui.paragraph(
            text: [
              # Line 1: Navigation & General
              @tui.text_line(spans: [
                @tui.text_span(content: "←/→", style: @hotkey_style),
                @tui.text_span(content: ": Navigate Tab  "),
                @tui.text_span(content: "v", style: @hotkey_style),
                @tui.text_span(content: ": Direction (#{@direction})  "),
                @tui.text_span(content: "q", style: @hotkey_style),
                @tui.text_span(content: ": Quit"),
              ]),
              # Line 2: Padding & Divider
              @tui.text_line(spans: [
                @tui.text_span(content: "h/l", style: @hotkey_style),
                @tui.text_span(content: ": Pad Left (#{@padding_left})  "),
                @tui.text_span(content: "j/k", style: @hotkey_style),
                @tui.text_span(content: ": Pad Right (#{@padding_right})  "),
                @tui.text_span(content: "d", style: @hotkey_style),
                @tui.text_span(content: ": Divider (#{@dividers[@divider_index]})  "),
                @tui.text_span(content: "Width: #{tabs.width}"),
              ]),
              # Line 3: Styles
              @tui.text_line(spans: [
                @tui.text_span(content: "space", style: @hotkey_style),
                @tui.text_span(content: ": Highlight (#{@styles[@style_index][:name]})  "),
                @tui.text_span(content: "x", style: @hotkey_style),
                @tui.text_span(content: ": Label (#{@styles[@label_style_index][:name]})  "),
                @tui.text_span(content: "space", style: @hotkey_style),
                @tui.text_span(content: ": Highlight (#{@styles[@style_index][:name]})  "),
                @tui.text_span(content: "x", style: @hotkey_style),
                @tui.text_span(content: ": Label (#{@styles[@label_style_index][:name]})"),
              ]),
              # Line 4: More Styles
              @tui.text_line(spans: [
                @tui.text_span(content: "z", style: @hotkey_style),
                @tui.text_span(content: ": Value (#{@styles[@value_style_index][:name]})  "),
                @tui.text_span(content: "b", style: @hotkey_style),
                @tui.text_span(content: ": Bar Set (#{@bar_sets[@bar_set_index][:name]})  "),
                @tui.text_span(content: "m", style: @hotkey_style),
                @tui.text_span(content: ": Mode (#{(@height_mode == :full) ? 'Full' : 'Mini'})  "),
                @tui.text_span(content: "g", style: @hotkey_style),
                @tui.text_span(content: ": Group Gap (#{@group_gap})"),
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
      @direction = (@direction == :vertical) ? :horizontal : :vertical
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
      @height_mode = (@height_mode == :full) ? :mini : :full
    in type: :key, code: "g"
      @group_gap = (@group_gap + 1) % 4
    else
      # Ignore other events
    end
  end
end

AppAnalytics.new.run if __FILE__ == $0
