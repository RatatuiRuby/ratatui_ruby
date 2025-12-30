# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class BoxDemoApp
  def initialize
    # Border Types (ratatui native styles)
    @border_types = [
      { name: "Plain", type: :plain },
      { name: "Rounded", type: :rounded },
      { name: "Double", type: :double },
      { name: "Thick", type: :thick },
      { name: "Quadrant Inside", type: :quadrant_inside },
      { name: "Quadrant Outside", type: :quadrant_outside }
    ]
    @border_type_index = 0

    # Custom Border Sets
    # NOTE: We define these ONCE in initialize for efficiency.
    @border_sets = [
      { name: "None", set: nil },
      { name: "Digits (Short)", set: {
        tl: "1", tr: "2", bl: "3", br: "4",
        vl: "5", vr: "6", ht: "7", hb: "8"
      }},
      { name: "Letters (Long)", set: {
        top_left: "A", top_right: "B", bottom_left: "C", bottom_right: "D",
        vertical_left: "E", vertical_right: "F", horizontal_top: "G", horizontal_bottom: "H"
      }}
    ]
    @border_set_index = 0

    @colors = [
      { name: "Green", color: "green" },
      { name: "Red", color: "red" },
      { name: "Blue", color: "blue" },
      { name: "Yellow", color: "yellow" },
      { name: "Magenta", color: "magenta" }
    ]
    @color_index = 0

    @title_alignments = [
      { name: "Left", alignment: :left },
      { name: "Center", alignment: :center },
      { name: "Right", alignment: :right }
    ]
    @title_alignment_index = 0

    @styles = [
      { name: "Default", style: nil },
      { name: "Blue on White", style: { fg: "blue", bg: "white", modifiers: [:bold] } }
    ]
    @style_index = 0

    @title_styles = [
      { name: "Default", style: nil },
      { name: "Yellow Bold Underlined", style: { fg: "yellow", modifiers: [:bold, :underlined] } }
    ]
    @title_style_index = 0

    @border_styles = [
      { name: "Default (no border style)", style: nil },
      { name: "Bold Red", style: { fg: "red", modifiers: [:bold] } },
      { name: "Cyan Italic", style: { fg: "cyan", modifiers: [:italic] } },
      { name: "Magenta Dim", style: { fg: "magenta", modifiers: [:dim] } }
    ]
    @border_style_index = 0

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
    # Get current values
    border_type_config = @border_types[@border_type_index]
    border_set_config = @border_sets[@border_set_index]
    
    color_config = @colors[@color_index]
    title_alignment_config = @title_alignments[@title_alignment_index]
    style_config = @styles[@style_index]
    title_style_config = @title_styles[@title_style_index]
    border_style_config = @border_styles[@border_style_index]

    # 1. State/View
    # Use border_style if provided, otherwise fall back to border_color
    effective_border_style = border_style_config[:style]
    effective_border_color = effective_border_style ? nil : (style_config[:style] ? nil : color_config[:color])

    # Show overridden status if border_set is active
    type_display = border_type_config[:name]
    if border_set_config[:set]
      type_display += " (Overridden)"
    end

    block = RatatuiRuby::Block.new(
      title: "Box Demo",
      title_alignment: title_alignment_config[:alignment],
      title_style: title_style_config[:style],
      borders: [:all],
      border_color: effective_border_color,
      border_style: effective_border_style,
      border_type: border_type_config[:type],
      border_set: border_set_config[:set],
      style: style_config[:style]
    )

    # Main content
    main_panel = RatatuiRuby::Paragraph.new(
      text: "Arrow Keys: Change Color\n\nCurrent Color: #{color_config[:name]}",
      block: block,
      fg: style_config[:style] ? nil : color_config[:color],
      style: style_config[:style],
      align: :center
    )

    # Bottom control panel
    control_panel = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            # Line 1: Main Controls
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "↑↓←→", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Color (#{color_config[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Quit")
            ]),
            # Line 2: Borders
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "space", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Border Type (#{type_display})  "),
              RatatuiRuby::Text::Span.new(content: "c", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Border Set (#{border_set_config[:name]})")
            ]),
            # Line 3: Styles
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "s", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Style (#{style_config[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "b", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Border Style (#{border_style_config[:name]})")
            ]),
            # Line 4: Title
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "enter", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Align Title (#{title_alignment_config[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "t", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Title Style (#{title_style_config[:name]})")
            ])
          ]
        )
      ]
    )

    # Vertical Layout
    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(6),
      ],
      children: [main_panel, control_panel]
    )

    # 2. Render
    RatatuiRuby.draw(layout)
  end

  def handle_input
    # 3. Events
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "up"
      @color_index = (@color_index - 1) % @colors.size
    in type: :key, code: "down"
      @color_index = (@color_index + 1) % @colors.size
    in type: :key, code: "left"
      @color_index = (@color_index - 1) % @colors.size
    in type: :key, code: "right"
      @color_index = (@color_index + 1) % @colors.size
    in type: :key, code: " "
      @border_type_index = (@border_type_index + 1) % @border_types.size
    in type: :key, code: "c"
      @border_set_index = (@border_set_index + 1) % @border_sets.size
    in type: :key, code: "enter"
      @title_alignment_index = (@title_alignment_index + 1) % @title_alignments.size
    in type: :key, code: "s"
      @style_index = (@style_index + 1) % @styles.size
    in type: :key, code: "t"
      @title_style_index = (@title_style_index + 1) % @title_styles.size
    in type: :key, code: "b"
      @border_style_index = (@border_style_index + 1) % @border_styles.size
    else
      nil
    end
  end
end

BoxDemoApp.new.run if __FILE__ == $0

