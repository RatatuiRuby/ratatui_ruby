# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates List widget with interactive attribute cycling.
class ListDemoApp
  def initialize
    @selected_index = nil

    @item_sets = [
      { name: "Colors", items: ["Red", "Yellow", "Green", "Cyan", "Blue", "Magenta"] },
      { name: "Fruits", items: ["Apple", "Banana", "Orange", "Grape", "Strawberry"] },
      { name: "Programming", items: ["Ruby", "Rust", "Python", "JavaScript", "Go", "C++"] },
      { name: "Numbers", items: ["One", "Two", "Three", "Four", "Five", "Six", "Seven"] }
    ]
    @item_set_index = 0

    @highlight_styles = [
      { name: "Blue Bold", style: RatatuiRuby::Style.new(fg: :blue, modifiers: [:bold]) },
      { name: "Yellow on Black", style: RatatuiRuby::Style.new(fg: :yellow, bg: :black) },
      { name: "Green Italic", style: RatatuiRuby::Style.new(fg: :green, modifiers: [:italic]) },
      { name: "White Reversed", style: RatatuiRuby::Style.new(fg: :white, modifiers: [:reversed]) },
      { name: "Cyan Bold", style: RatatuiRuby::Style.new(fg: :cyan, modifiers: [:bold]) }
    ]
    @highlight_style_index = 0

    @highlight_symbols = [
      { name: ">> ", symbol: ">> " },
      { name: "▶ ", symbol: "▶ " },
      { name: "→ ", symbol: "→ " },
      { name: "• ", symbol: "• " },
      { name: "★ ", symbol: "★ " }
    ]
    @highlight_symbol_index = 0

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

    @repeat_modes = [
      { name: "Off", repeat: false },
      { name: "On", repeat: true }
    ]
    @repeat_index = 0

    @base_styles = [
      { name: "None", style: nil },
      { name: "Dark Gray", style: RatatuiRuby::Style.new(fg: :dark_gray) },
      { name: "White on Black", style: RatatuiRuby::Style.new(fg: :white, bg: :black) }
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
    items = @item_sets[@item_set_index][:items]
    selection_label = @selected_index.nil? ? "none" : @selected_index.to_s
    direction_config = @directions[@direction_index]
    spacing_config = @highlight_spacings[@highlight_spacing_index]
    repeat_config = @repeat_modes[@repeat_index]
    highlight_style_config = @highlight_styles[@highlight_style_index]
    highlight_symbol_config = @highlight_symbols[@highlight_symbol_index]
    base_style_config = @base_styles[@base_style_index]

    # Main content area with multiple list examples
    main_content = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(1),
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(4)
      ],
      children: [
        RatatuiRuby::Paragraph.new(
          text: "List Widget Demo - Cycle attributes with hotkeys"
        ),
        # Main interactive list
        RatatuiRuby::List.new(
          items:,
          selected_index: @selected_index,
          style: base_style_config[:style],
          highlight_style: highlight_style_config[:style],
          highlight_symbol: highlight_symbol_config[:symbol],
          repeat_highlight_symbol: repeat_config[:repeat],
          highlight_spacing: spacing_config[:spacing],
          direction: direction_config[:direction],
          block: RatatuiRuby::Block.new(
            title: "Interactive List",
            borders: [:all]
          )
        ),
        # Info display
        RatatuiRuby::Block.new(
          title: "Current State",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                "Item Set: #{@item_sets[@item_set_index][:name]}",
                "Selection: #{selection_label}",
                "Direction: #{direction_config[:name]}",
                "Spacing: #{spacing_config[:name]}"
              ]
            )
          ]
        )
      ]
    )

    # Sidebar with controls
    sidebar = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(7),
        RatatuiRuby::Constraint.length(7),
        RatatuiRuby::Constraint.length(6),
        RatatuiRuby::Constraint.length(5),
        RatatuiRuby::Constraint.length(5),
        RatatuiRuby::Constraint.fill(1)
      ],
      children: [
        # Item set control
        RatatuiRuby::Block.new(
          title: "Item Set",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                "i: Cycle",
                "  #{@item_sets[@item_set_index][:name]}"
              ]
            )
          ]
        ),
        # Selection control
        RatatuiRuby::Block.new(
          title: "Selection",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                "↑/↓: Navigate",
                "x: Toggle (#{selection_label})"
              ]
            )
          ]
        ),
        # Highlight style control
        RatatuiRuby::Block.new(
          title: "Highlight Style",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                "h: Cycle",
                "  #{highlight_style_config[:name]}"
              ]
            )
          ]
        ),
        # Highlight symbol control
        RatatuiRuby::Block.new(
          title: "Symbol",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                "y: Cycle",
                "  #{highlight_symbol_config[:name]}"
              ]
            )
          ]
        ),
        # Layout options
        RatatuiRuby::Block.new(
          title: "Layout",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                "d: Direction",
                "  #{direction_config[:name]}",
                "s: Spacing",
                "  #{spacing_config[:name]}"
              ]
            )
          ]
        ),
        # Display options
        RatatuiRuby::Block.new(
          title: "Options",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                "b: Base Style",
                "  #{base_style_config[:name]}",
                "r: Repeat Symbol",
                "  #{repeat_config[:name]}",
                "",
                "q: Quit"
              ]
            )
          ]
        )
      ]
    )

    # Combine layouts
    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.new(type: :percentage, value: 70),
        RatatuiRuby::Constraint.new(type: :percentage, value: 30)
      ],
      children: [main_content, sidebar]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "i"
      @item_set_index = (@item_set_index + 1) % @item_sets.size
      @selected_index = nil
    in type: :key, code: "up"
      items = @item_sets[@item_set_index][:items]
      @selected_index = (@selected_index || 0) - 1
      @selected_index = items.size - 1 if @selected_index.negative?
    in type: :key, code: "down"
      items = @item_sets[@item_set_index][:items]
      @selected_index = ((@selected_index || -1) + 1) % items.size
    in type: :key, code: "x"
      @selected_index = @selected_index.nil? ? 0 : nil
    in type: :key, code: "h"
      @highlight_style_index = (@highlight_style_index + 1) % @highlight_styles.size
    in type: :key, code: "y"
      @highlight_symbol_index = (@highlight_symbol_index + 1) % @highlight_symbols.size
    in type: :key, code: "d"
      @direction_index = (@direction_index + 1) % @directions.size
    in type: :key, code: "s"
      @highlight_spacing_index = (@highlight_spacing_index + 1) % @highlight_spacings.size
    in type: :key, code: "b"
      @base_style_index = (@base_style_index + 1) % @base_styles.size
    in type: :key, code: "r"
      @repeat_index = (@repeat_index + 1) % @repeat_modes.size
    else
      nil
    end
  end
end

ListDemoApp.new.run if __FILE__ == $PROGRAM_NAME
