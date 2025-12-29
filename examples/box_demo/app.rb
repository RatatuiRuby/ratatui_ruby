# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class BoxDemoApp
  def initialize
    @border_types = [
      { name: "Plain", type: :plain },
      { name: "Rounded", type: :rounded },
      { name: "Double", type: :double },
      { name: "Thick", type: :thick },
      { name: "Quadrant Inside", type: :quadrant_inside },
      { name: "Quadrant Outside", type: :quadrant_outside }
    ]
    @border_index = 0

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
    border_config = @border_types[@border_index]
    color_config = @colors[@color_index]
    title_alignment_config = @title_alignments[@title_alignment_index]
    style_config = @styles[@style_index]
    title_style_config = @title_styles[@title_style_index]

    # 1. State/View
    effective_border_color = style_config[:style] ? nil : color_config[:color]

    block = RatatuiRuby::Block.new(
      title: "Box Demo",
      title_alignment: title_alignment_config[:alignment],
      title_style: title_style_config[:style],
      borders: [:all],
      border_color: effective_border_color,
      border_type: border_config[:type],
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

    # Sidebar
    sidebar = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "MAIN", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "q: Quit",
            "↑↓←→: Color (#{color_config[:name]})",
            "",
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "BORDER", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "space: Type (#{border_config[:name]})",
            "",
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "TITLE", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "enter: Align (#{title_alignment_config[:name]})",
            "t: Style (#{title_style_config[:name]})",
            "",
            RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "CONTENT", style: RatatuiRuby::Style.new(modifiers: [:bold]))]),
            "s: Style (#{style_config[:name]})",
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
      children: [main_panel, sidebar]
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
      @border_index = (@border_index + 1) % @border_types.size
    in type: :key, code: "enter"
      @title_alignment_index = (@title_alignment_index + 1) % @title_alignments.size
    in type: :key, code: "s"
      @style_index = (@style_index + 1) % @styles.size
    in type: :key, code: "t"
      @title_style_index = (@title_style_index + 1) % @title_styles.size
    else
      nil
    end
  end
end

BoxDemoApp.new.run if __FILE__ == $0
