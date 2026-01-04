# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates the Block widget with interactive attribute cycling.
#
# Blocks are the foundation of terminal layouts, providing structure, borders, and titles.
# This demo showcases all available parameters, including advanced title positioning,
# directional padding, and custom border sets.
#
# === Examples
#
# Run the demo from the terminal:
#
#   ruby examples/widget_block/app.rb
#
# rdoc-image:/doc/images/widget_block.png
class WidgetBlock
  def initialize
    @title_configs = [
      { name: "None", title: nil },
      { name: "Main Title", title: "Main Title" },
    ]
    @title_index = 1

    @titles_configs = [
      { name: "None", titles: [] },
      {
name: "Top + Bottom",
titles: [
  { content: "Top Right", alignment: :right, position: :top },
  { content: "Bottom Left", alignment: :left, position: :bottom },
      ],
},
      {
name: "Complex",
titles: [
  { content: "★ Left ★", alignment: :left, position: :top },
  { content: "Center", alignment: :center, position: :top },
  { content: "Right", alignment: :right, position: :top },
  { content: "Bottom Center", alignment: :center, position: :bottom },
      ],
},
    ]
    @titles_index = 1

    @alignment_configs = [
      { name: "Left", alignment: :left },
      { name: "Center", alignment: :center },
      { name: "Right", alignment: :right },
    ]
    @alignment_index = 1 # Center

    @border_configs = [
      { name: "All", borders: [:all] },
      { name: "Top/Bottom", borders: [:top, :bottom] },
      { name: "Left/Right", borders: [:left, :right] },
      { name: "None", borders: [] },
    ]
    @border_index = 0

    @border_type_configs = [
      { name: "Rounded", type: :rounded },
      { name: "Plain", type: :plain },
      { name: "Double", type: :double },
      { name: "Thick", type: :thick },
      { name: "Quadrant Inside", type: :quadrant_inside },
      { name: "Quadrant Outside", type: :quadrant_outside },
      {
name: "Custom Set",
type: nil,
set: {
        top_left: "1",
        top_right: "2",
        bottom_left: "3",
        bottom_right: "4",
        vertical_left: "5",
        vertical_right: "6",
        horizontal_top: "7",
        horizontal_bottom: "8",
      },
},
    ]
    @border_type_index = 0

    @padding_configs = [
      { name: "Uniform (2)", padding: 2 },
      { name: "None (0)", padding: 0 },
      { name: "Directional (L:4, T:2)", padding: [4, 0, 2, 0] },
      { name: "Narrow (H:1, V:0)", padding: [1, 1, 0, 0] },
    ]
    @padding_index = 0
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui

      @title_styles = [
        { name: "None", style: nil },
        { name: "Magenta Bold", style: @tui.style(fg: :magenta, modifiers: [:bold]) },
        { name: "Cyan Bold", style: @tui.style(fg: :cyan, modifiers: [:bold]) },
        { name: "Yellow Italic", style: @tui.style(fg: :yellow, modifiers: [:italic]) },
      ]
      @title_style_index = 1 # Magenta Bold

      @border_styles = [
        { name: "Cyan", style: @tui.style(fg: :cyan) },
        { name: "Magenta Bold", style: @tui.style(fg: :magenta, modifiers: [:bold]) },
        { name: "None", style: nil },
        { name: "Blue on White", style: @tui.style(fg: :blue, bg: :white) },
      ]
      @border_style_index = 0

      @base_styles = [
        { name: "Dark Gray", style: @tui.style(fg: :dark_gray) },
        { name: "None", style: nil },
        { name: "White on Black", style: @tui.style(fg: :white, bg: :black) },
      ]
      @base_style_index = 1

      @hotkey_style = @tui.style(modifiers: [:bold, :underlined])

      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    end
  end

  private def render
    title_config = @title_configs[@title_index]
    titles_config = @titles_configs[@titles_index]
    alignment_config = @alignment_configs[@alignment_index]
    title_style_config = @title_styles[@title_style_index]
    border_config = @border_configs[@border_index]
    border_type_config = @border_type_configs[@border_type_index]
    border_style_config = @border_styles[@border_style_index]
    base_style_config = @base_styles[@base_style_index]
    padding_config = @padding_configs[@padding_index]

    @tui.draw do |frame|
      main_area, control_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(10),
        ]
      )

      # Render the demo block
      demo_block = @tui.block(
        title: title_config[:title],
        titles: titles_config[:titles],
        title_alignment: alignment_config[:alignment],
        title_style: title_style_config[:style],
        borders: border_config[:borders],
        border_type: border_type_config[:type],
        border_set: border_type_config[:set],
        border_style: border_style_config[:style],
        style: base_style_config[:style],
        padding: padding_config[:padding]
      )

      # Paragraph inside the block to show padding/content interaction
      content = @tui.paragraph(
        text: "This paragraph is rendered inside the Block widget.\n" \
          "You can see how padding and base style affect this content.\n\n" \
          "Current State:\n" \
          "• Padding: #{padding_config[:name]}\n" \
          "• Borders: #{border_config[:name]}\n" \
          "• Type: #{border_type_config[:name]}",
        block: demo_block
      )
      frame.render_widget(content, main_area)

      # Render control panel
      control_panel = @tui.block(
        title: "Controls",
        borders: [:all],
        children: [
          @tui.paragraph(
            text: [
              @tui.text_line(spans: [
                @tui.text_span(content: "t", style: @hotkey_style),
                @tui.text_span(content: ": Title (#{title_config[:name]})  "),
                @tui.text_span(content: "a", style: @hotkey_style),
                @tui.text_span(content: ": Alignment (#{alignment_config[:name]})  "),
                @tui.text_span(content: "s", style: @hotkey_style),
                @tui.text_span(content: ": Title Style (#{title_style_config[:name]})"),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "e", style: @hotkey_style),
                @tui.text_span(content: ": Additional Titles (#{titles_config[:name]})"),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "b", style: @hotkey_style),
                @tui.text_span(content: ": Borders (#{border_config[:name]})  "),
                @tui.text_span(content: "y", style: @hotkey_style),
                @tui.text_span(content: ": Border Type (#{border_type_config[:name]})"),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "c", style: @hotkey_style),
                @tui.text_span(content: ": Border Style (#{border_style_config[:name]})  "),
                @tui.text_span(content: "p", style: @hotkey_style),
                @tui.text_span(content: ": Padding (#{padding_config[:name]})"),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "f", style: @hotkey_style),
                @tui.text_span(content: ": Base Style (#{base_style_config[:name]})  "),
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
    in type: :key, code: "t"
      @title_index = (@title_index + 1) % @title_configs.size
    in type: :key, code: "e"
      @titles_index = (@titles_index + 1) % @titles_configs.size
    in type: :key, code: "a"
      @alignment_index = (@alignment_index + 1) % @alignment_configs.size
    in type: :key, code: "s"
      @title_style_index = (@title_style_index + 1) % @title_styles.size
    in type: :key, code: "b"
      @border_index = (@border_index + 1) % @border_configs.size
    in type: :key, code: "y"
      @border_type_index = (@border_type_index + 1) % @border_type_configs.size
    in type: :key, code: "c"
      @border_style_index = (@border_style_index + 1) % @border_styles.size
    in type: :key, code: "p"
      @padding_index = (@padding_index + 1) % @padding_configs.size
    in type: :key, code: "f"
      @base_style_index = (@base_style_index + 1) % @base_styles.size
    else
      nil
    end
  end
end

WidgetBlock.new.run if __FILE__ == $PROGRAM_NAME
