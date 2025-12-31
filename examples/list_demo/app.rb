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
      {
        name: "Large List",
        items: (1..200).map { |i| "Item #{i}" },
      },
      {
        name: "Colors",
        items: [
          "Red",
          "Orange",
          "Yellow",
          "Green",
          "Cyan",
          "Blue",
          "Indigo",
          "Violet",
          "Scarlet",
          "Crimson",
          "Maroon",
          "Brown",
          "Tan",
          "Beige",
          "Khaki",
          "Gold",
          "Silver",
          "White",
          "Gray",
          "Black",
          "Pink",
          "Magenta",
          "Turquoise",
          "Teal",
          "Coral",
          "Salmon",
          "Peach",
          "Lavender",
          "Lilac",
          "Olive",
          "Lime",
          "Navy",
          "Charcoal",
          "Ivory",
          "Azure",
        ],
      },
      {
        name: "Fruits",
        items: [
          "Apple",
          "Apricot",
          "Avocado",
          "Banana",
          "Blueberry",
          "Blackberry",
          "Cherry",
          "Cranberry",
          "Cucumber",
          "Date",
          "Dragonfruit",
          "Elderberry",
          "Fig",
          "Grape",
          "Grapefruit",
          "Guava",
          "Honeydew",
          "Huckleberry",
          "Jackfruit",
          "Kiwi",
          "Kumquat",
          "Lemon",
          "Lime",
          "Lychee",
          "Mango",
          "Melon",
          "Mulberry",
          "Nectarine",
          "Olive",
          "Orange",
          "Papaya",
          "Passion Fruit",
          "Peach",
          "Pear",
          "Persimmon",
          "Pineapple",
          "Plum",
          "Pomegranate",
          "Prune",
          "Rambutan",
          "Raspberry",
          "Starfruit",
          "Strawberry",
          "Tangerine",
          "Watermelon",
          "Ugli Fruit",
        ],
      },
      {
        name: "Programming",
        items: [
          "Ruby",
          "Rust",
          "Python",
          "JavaScript",
          "Go",
          "C++",
          "C#",
          "Java",
          "Kotlin",
          "Swift",
          "Objective-C",
          "PHP",
          "TypeScript",
          "Perl",
          "Lua",
          "R",
          "Scala",
          "Haskell",
          "Elixir",
          "Clojure",
          "Groovy",
          "Closure",
          "VB.NET",
          "F#",
          "Erlang",
          "Lisp",
          "Scheme",
          "Prolog",
          "Fortran",
          "COBOL",
          "Pascal",
          "Delphi",
          "Ada",
          "Bash",
          "Sh",
          "Tcl",
          "Awk",
          "sed",
          "Vim Script",
          "PowerShell",
          "Batch",
          "Assembly",
          "Wasm",
          "WebAssembly",
          "Julia",
          "Matlab",
          "Octave",
          "BASIC",
        ],
      },
    ]
    @item_set_index = 0

    @highlight_styles = [
      { name: "Blue Bold", style: RatatuiRuby::Style.new(fg: :blue, modifiers: [:bold]) },
      { name: "Yellow on Black", style: RatatuiRuby::Style.new(fg: :yellow, bg: :black) },
      { name: "Green Italic", style: RatatuiRuby::Style.new(fg: :green, modifiers: [:italic]) },
      { name: "White Reversed", style: RatatuiRuby::Style.new(fg: :white, modifiers: [:reversed]) },
      { name: "Cyan Bold", style: RatatuiRuby::Style.new(fg: :cyan, modifiers: [:bold]) },
    ]
    @highlight_style_index = 0

    @highlight_symbols = [
      { name: ">> ", symbol: ">> " },
      { name: "▶ ", symbol: "▶ " },
      { name: "→ ", symbol: "→ " },
      { name: "• ", symbol: "• " },
      { name: "★ ", symbol: "★ " },
    ]
    @highlight_symbol_index = 0

    @directions = [
      { name: "Top to Bottom", direction: :top_to_bottom },
      { name: "Bottom to Top", direction: :bottom_to_top },
    ]
    @direction_index = 0

    @highlight_spacings = [
      { name: "When Selected", spacing: :when_selected },
      { name: "Always", spacing: :always },
      { name: "Never", spacing: :never },
    ]
    @highlight_spacing_index = 0

    @repeat_modes = [
      { name: "Off", repeat: false },
      { name: "On", repeat: true },
    ]
    @repeat_index = 0

    @base_styles = [
      { name: "None", style: nil },
      { name: "Dark Gray", style: RatatuiRuby::Style.new(fg: :dark_gray) },
      { name: "White on Black", style: RatatuiRuby::Style.new(fg: :white, bg: :black) },
    ]
    @base_style_index = 0

    @scroll_paddings = [
      { name: "None", padding: nil },
      { name: "1 item", padding: 1 },
      { name: "2 items", padding: 2 },
    ]
    @scroll_padding_index = 0
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

  private def render
    items = @item_sets[@item_set_index][:items]
    selection_label = @selected_index.nil? ? "none" : @selected_index.to_s
    direction_config = @directions[@direction_index]
    spacing_config = @highlight_spacings[@highlight_spacing_index]
    repeat_config = @repeat_modes[@repeat_index]
    highlight_style_config = @highlight_styles[@highlight_style_index]
    highlight_symbol_config = @highlight_symbols[@highlight_symbol_index]
    base_style_config = @base_styles[@base_style_index]
    scroll_padding_config = @scroll_paddings[@scroll_padding_index]

    # Main list area
    main_content = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(1),
        RatatuiRuby::Constraint.fill(1),
      ],
      children: [
        RatatuiRuby::Paragraph.new(
          text: "List Widget Demo - Interactive Attribute Cycling"
        ),
        RatatuiRuby::List.new(
          items:,
          selected_index: @selected_index,
          style: base_style_config[:style],
          highlight_style: highlight_style_config[:style],
          highlight_symbol: highlight_symbol_config[:symbol],
          repeat_highlight_symbol: repeat_config[:repeat],
          highlight_spacing: spacing_config[:spacing],
          direction: direction_config[:direction],
          scroll_padding: scroll_padding_config[:padding],
          block: RatatuiRuby::Block.new(
            title: "#{@item_sets[@item_set_index][:name]} (Selection: #{selection_label})",
            borders: [:all]
          )
        ),
      ]
    )

    # Bottom control panel with full width
    hotkey_style = RatatuiRuby::Style.new(modifiers: [:bold, :underlined])
    control_panel = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "i", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Items  "),
              RatatuiRuby::Text::Span.new(content: "↑/↓", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Navigate  "),
              RatatuiRuby::Text::Span.new(content: "x", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Select  "),
              RatatuiRuby::Text::Span.new(content: "h", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Highlight (#{highlight_style_config[:name]})"),
            ]),
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "y", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Symbol (#{highlight_symbol_config[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "d", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Direction (#{direction_config[:name]})"),
            ]),
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "s", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Spacing (#{spacing_config[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "p", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Scroll Padding (#{scroll_padding_config[:name]})"),
            ]),
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "b", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Base (#{base_style_config[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "r", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Repeat (#{repeat_config[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "q", style: hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Quit"),
            ]),
          ]
        ),
      ]
    )

    # Combine layouts vertically
    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(7),
      ],
      children: [main_content, control_panel]
    )

    RatatuiRuby.draw(layout)
  end

  private def handle_input
    case RatatuiRuby.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
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
    in type: :key, code: "p"
      @scroll_padding_index = (@scroll_padding_index + 1) % @scroll_paddings.size
    else
      nil
    end
  end
end

ListDemoApp.new.run if __FILE__ == $PROGRAM_NAME
