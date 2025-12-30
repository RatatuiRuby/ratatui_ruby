#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demo: Scrollable Paragraph
# Shows how to scroll through long text content using arrow keys
class ScrollTextApp
  def initialize
    @scroll_x = 0
    @scroll_y = 0

    @lines = (1..100).map { |i| "Line #{i}: This is a long line of text that can be scrolled horizontally" }
    @hotkey_style = RatatuiRuby::Style.new(modifiers: [:bold, :underlined])
  end

  def run
    RatatuiRuby.run do
      loop do
        draw
        break if handle_input == :quit
      end
    end
  end

  def render
    draw
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "up"
      @scroll_y = [@scroll_y - 1, 0].max
    in type: :key, code: "down"
      @scroll_y = [@scroll_y + 1, @lines.length].min
    in type: :key, code: "left"
      @scroll_x = [@scroll_x - 1, 0].max
    in type: :key, code: "right"
      @scroll_x = [@scroll_x + 1, 100].min
    else
      nil
    end
  end

  private

  def draw
    text = @lines.join("\n")
    
    # Main content
    main_paragraph = RatatuiRuby::Paragraph.new(
      text: text,
      scroll: [@scroll_y, @scroll_x],
      block: RatatuiRuby::Block.new(
        title: "Scrollable Text (#{text.lines.count} lines)",
        borders: [:all]
      )
    )

    # Bottom control panel
    control_panel = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "NAVIGATION (Size: #{main_paragraph.line_count(65535)}x#{main_paragraph.line_width})", style: RatatuiRuby::Style.new(modifiers: [:bold]))
            ]),
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "↑/↓", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Vert Scroll (#{@scroll_y}/#{main_paragraph.line_count(65535)})  "),
              RatatuiRuby::Text::Span.new(content: "←/→", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Horz Scroll (#{@scroll_x}/#{main_paragraph.line_width})  "),
              RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Quit")
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
        RatatuiRuby::Constraint.length(5),
      ],
      children: [main_paragraph, control_panel]
    )

    RatatuiRuby.draw(layout)
  end
end

ScrollTextApp.new.run if __FILE__ == $PROGRAM_NAME
