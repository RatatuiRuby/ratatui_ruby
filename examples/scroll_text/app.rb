#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demo: Scrollable Paragraph
# Shows how to scroll through long text content using arrow keys
class ScrollTextDemo
  def initialize
    @scroll_x = 0
    @scroll_y = 0
    @lines = (1..100).map { |i| "Line #{i}: This is a long line of text that can be scrolled horizontally" }
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
        title: "Scrollable Text",
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
            "↑: Scroll Up (#{@scroll_y})",
            "↓: Scroll Down",
            "←: Scroll Left (#{@scroll_x})",
            "→: Scroll Right",
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
      children: [main_paragraph, sidebar]
    )

    RatatuiRuby.draw(layout)
  end
end

ScrollTextDemo.new.run if __FILE__ == $PROGRAM_NAME
