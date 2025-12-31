# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates List widget with interactive attribute cycling.
class WidgetListDemo
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

    @highlight_symbol_names = [">> ", "▶ ", "→ ", "• ", "★ "]
    @highlight_symbol_index = 0

    @direction_configs = [
      { name: "Top to Bottom", direction: :top_to_bottom },
      { name: "Bottom to Top", direction: :bottom_to_top },
    ]
    @direction_index = 0

    @highlight_spacing_configs = [
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

    @scroll_padding_configs = [
      { name: "None", padding: nil },
      { name: "1 item", padding: 1 },
      { name: "2 items", padding: 2 },
    ]
    @scroll_padding_index = 0
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      # Initialize styles that require @tui
      @highlight_styles = [
        { name: "Blue Bold", style: @tui.style(fg: :blue, modifiers: [:bold]) },
        { name: "Yellow on Black", style: @tui.style(fg: :yellow, bg: :black) },
        { name: "Green Italic", style: @tui.style(fg: :green, modifiers: [:italic]) },
        { name: "White Reversed", style: @tui.style(fg: :white, modifiers: [:reversed]) },
        { name: "Cyan Bold", style: @tui.style(fg: :cyan, modifiers: [:bold]) },
      ]
      @highlight_style_index = 0

      @base_styles = [
        { name: "None", style: nil },
        { name: "Dark Gray", style: @tui.style(fg: :dark_gray) },
        { name: "White on Black", style: @tui.style(fg: :white, bg: :black) },
      ]
      @base_style_index = 0

      @hotkey_style = @tui.style(modifiers: [:bold, :underlined])

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
    direction_config = @direction_configs[@direction_index]
    spacing_config = @highlight_spacing_configs[@highlight_spacing_index]
    repeat_config = @repeat_modes[@repeat_index]
    highlight_style_config = @highlight_styles[@highlight_style_index]
    highlight_symbol = @highlight_symbol_names[@highlight_symbol_index]
    base_style_config = @base_styles[@base_style_index]
    scroll_padding_config = @scroll_padding_configs[@scroll_padding_index]

    @tui.draw do |frame|
      # Split into main content and control panel
      main_area, control_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(7),
        ]
      )

      # Split main content into title and list
      title_area, list_area = @tui.layout_split(
        main_area,
        direction: :vertical,
        constraints: [
          @tui.constraint_length(1),
          @tui.constraint_fill(1),
        ]
      )

      # Render title
      title = @tui.paragraph(text: "List Widget Demo - Interactive Attribute Cycling")
      frame.render_widget(title, title_area)

      # Render list
      list = @tui.list(
        items:,
        selected_index: @selected_index,
        style: base_style_config[:style],
        highlight_style: highlight_style_config[:style],
        highlight_symbol:,
        repeat_highlight_symbol: repeat_config[:repeat],
        highlight_spacing: spacing_config[:spacing],
        direction: direction_config[:direction],
        scroll_padding: scroll_padding_config[:padding],
        block: @tui.block(
          title: "#{@item_sets[@item_set_index][:name]} (Selection: #{selection_label})",
          borders: [:all]
        )
      )
      frame.render_widget(list, list_area)

      # Render control panel
      control_panel = @tui.block(
        title: "Controls",
        borders: [:all],
        children: [
          @tui.paragraph(
            text: [
              @tui.text_line(spans: [
                @tui.text_span(content: "i", style: @hotkey_style),
                @tui.text_span(content: ": Items  "),
                @tui.text_span(content: "↑/↓", style: @hotkey_style),
                @tui.text_span(content: ": Navigate  "),
                @tui.text_span(content: "x", style: @hotkey_style),
                @tui.text_span(content: ": Select  "),
                @tui.text_span(content: "h", style: @hotkey_style),
                @tui.text_span(content: ": Highlight (#{highlight_style_config[:name]})"),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "y", style: @hotkey_style),
                @tui.text_span(content: ": Symbol (#{highlight_symbol})  "),
                @tui.text_span(content: "d", style: @hotkey_style),
                @tui.text_span(content: ": Direction (#{direction_config[:name]})"),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "s", style: @hotkey_style),
                @tui.text_span(content: ": Spacing (#{spacing_config[:name]})  "),
                @tui.text_span(content: "p", style: @hotkey_style),
                @tui.text_span(content: ": Scroll Padding (#{scroll_padding_config[:name]})"),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "b", style: @hotkey_style),
                @tui.text_span(content: ": Base (#{base_style_config[:name]})  "),
                @tui.text_span(content: "r", style: @hotkey_style),
                @tui.text_span(content: ": Repeat (#{repeat_config[:name]})  "),
                @tui.text_span(content: "q", style: @hotkey_style),
                @tui.text_span(content: ": Quit"),
              ]),
            ]
          ),
        ]
      )
      frame.render_widget(control_panel, control_area)
    end
  end

  private def handle_input
    case @tui.poll_event
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
      @highlight_symbol_index = (@highlight_symbol_index + 1) % @highlight_symbol_names.size
    in type: :key, code: "d"
      @direction_index = (@direction_index + 1) % @direction_configs.size
    in type: :key, code: "s"
      @highlight_spacing_index = (@highlight_spacing_index + 1) % @highlight_spacing_configs.size
    in type: :key, code: "b"
      @base_style_index = (@base_style_index + 1) % @base_styles.size
    in type: :key, code: "r"
      @repeat_index = (@repeat_index + 1) % @repeat_modes.size
    in type: :key, code: "p"
      @scroll_padding_index = (@scroll_padding_index + 1) % @scroll_padding_configs.size
    else
      nil
    end
  end
end

WidgetListDemo.new.run if __FILE__ == $PROGRAM_NAME
