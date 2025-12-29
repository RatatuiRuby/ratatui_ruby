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
    
    paragraph = RatatuiRuby::Paragraph.new(
      text: text,
      scroll: [@scroll_y, @scroll_x],
      block: RatatuiRuby::Block.new(
        title: "Scrollable Text (X: #{@scroll_x}, Y: #{@scroll_y}) - Arrow keys to scroll, 'q' to quit",
        borders: [:all]
      )
    )

    RatatuiRuby.draw(paragraph)
  end
end

ScrollTextDemo.new.run if __FILE__ == $PROGRAM_NAME
