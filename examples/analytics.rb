# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Analytics Dashboard Example
# Demonstrates Tabs and BarChart widgets.

class AnalyticsApp
  def initialize
    @selected_tab = 0
    @tabs = ["Revenue", "Traffic", "Errors"]
    @style_index = 0
    @styles = [
      RatatuiRuby::Style.new(fg: :yellow, modifiers: [:bold]),
      RatatuiRuby::Style.new(fg: :blue, bg: :white, modifiers: [:italic]),
      RatatuiRuby::Style.new(fg: :red, modifiers: [:underlined]),
      RatatuiRuby::Style.new(modifiers: [:reversed])
    ]
    @divider_index = 0
    @dividers = [" | ", " • ", " > ", " / "]
    @base_style_index = 0
    @base_styles = [
      nil, # Default
      RatatuiRuby::Style.new(fg: :white, bg: :dark_gray),
      RatatuiRuby::Style.new(fg: :white, bg: :blue),
      RatatuiRuby::Style.new(modifiers: [:italic])
    ]
    @padding_left = 0
    @padding_right = 0
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    ensure
      RatatuiRuby.restore_terminal
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

    # Build the UI
    ui = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.new(type: :length, value: 3),
        RatatuiRuby::Constraint.new(type: :min, value: 0),
      ],
      children: [
        RatatuiRuby::Tabs.new(
          titles: @tabs,
          selected_index: @selected_tab,
          block: RatatuiRuby::Block.new(
            title: "Views (q: Quit) [pad L:#{@padding_left} R:#{@padding_right}]",
            titles: [
              { content: " Space:Highlight | s:Style | d:Divider | h/l:PadL | H/L:PadR ", position: :bottom, alignment: :center }
            ],
            borders: [:all]
          ),
          divider: @dividers[@divider_index],
          highlight_style: @styles[@style_index],
          style: @base_styles[@base_style_index],
          padding_left: @padding_left,
          padding_right: @padding_right
        ),
        RatatuiRuby::BarChart.new(
          data:,
          bar_width: 10,
          style: bar_style,
          block: RatatuiRuby::Block.new(title: "Analytics: #{@tabs[@selected_tab]}", borders: [:all])
        ),
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
    in type: :key, code: "H", modifiers: ["shift"]
      @padding_right = [@padding_right - 1, 0].max
    in type: :key, code: "L", modifiers: ["shift"]
      @padding_right += 1
    else
      # Ignore other events
    end
  end
end

AnalyticsApp.new.run if __FILE__ == $0
