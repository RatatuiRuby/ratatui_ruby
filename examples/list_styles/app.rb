# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Styled List Example
# Demonstrates advanced styling options for the List widget.
class ListStylesApp
  attr_reader :selected_index, :highlight_spacing

  def initialize
    @items = ["Item 1", "Item 2", "Item 3"]
    @selected_index = nil

    @directions = [
      { name: "Top to Bottom", direction: :top_to_bottom },
      { name: "Bottom to Top", direction: :bottom_to_top }
    ]
    @direction_index = 0

    @highlight_spacings = [
      { name: "When Selected", spacing: :when_selected },
      { name: "Always", spacing: :always },
      { name: "Never", spacing: :never }
    ]
    @highlight_spacing_index = 0
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
    selection_label = @selected_index.nil? ? "none" : @selected_index.to_s
    direction_config = @directions[@direction_index]
    spacing_config = @highlight_spacings[@highlight_spacing_index]

    # Main content
    main_list = RatatuiRuby::List.new(
      items: @items,
      selected_index: @selected_index,
      style: RatatuiRuby::Style.new(fg: :white, bg: :black),
      highlight_style: RatatuiRuby::Style.new(fg: :blue, bg: :white, modifiers: [:bold]),
      highlight_symbol: ">> ",
      highlight_spacing: spacing_config[:spacing],
      direction: direction_config[:direction],
      block: RatatuiRuby::Block.new(
        title: "Items",
        borders: [:all]
      )
    )

    # Sidebar
    sidebar = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "NAVIGATION", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "q: Quit",
            "↑/↓: Select (#{selection_label})",
            "x: Toggle Selection",
            "",
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "LIST", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "d: Direction",
            "  #{direction_config[:name]}",
            "s: Spacing",
            "  #{spacing_config[:name]}",
          ].flatten
        )
      ]
    )

    # Layout
    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.new(type: :percentage, value: 70),
        RatatuiRuby::Constraint.new(type: :percentage, value: 30),
      ],
      children: [main_list, sidebar]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "up"
      @selected_index = (@selected_index || 0) - 1
      @selected_index = @items.size - 1 if @selected_index.negative?
    in type: :key, code: "down"
      @selected_index = ((@selected_index || -1) + 1) % @items.size
    in type: :key, code: "d"
      @direction_index = (@direction_index + 1) % @directions.size
    in type: :key, code: "s"
      @highlight_spacing_index = (@highlight_spacing_index + 1) % @highlight_spacings.size
    in type: :key, code: "x"
      @selected_index = @selected_index.nil? ? 0 : nil
    else
      nil
    end
  end
end

ListStylesApp.new.run if __FILE__ == $PROGRAM_NAME
