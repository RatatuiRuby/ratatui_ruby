# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Simple Scrollbar Demo
class ScrollbarDemo
  def initialize
    @scroll_position = 0
    @content_length = 50
    @lines = (1..@content_length).map { |i| "Line #{i}" }
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        draw
        event = RatatuiRuby.poll_event
        break if event && event[:type] == :key && event[:code] == "q"

        handle_event(event)
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  private def handle_event(event)
    return unless event && event[:type] == :mouse

    case event[:kind]
    when :scroll_up
      @scroll_position = [@scroll_position - 1, 0].max
    when :scroll_down
      @scroll_position = [@scroll_position + 1, @content_length].min
    end
  end

  private def draw
    # Calculate visible lines based on scroll position
    # In a real app, you'd want to know the height of the available area.
    # For this demo, we'll just show all lines but offset the text.
    visible_lines = @lines[@scroll_position..-1] || []

    # Paragraph with content
    p = RatatuiRuby::Paragraph.new(
      text: visible_lines.join("\n"),
      block: RatatuiRuby::Block.new(title: "Scroll with Mouse Wheel", borders: [:all])
    )

    # Scrollbar on the right
    s = RatatuiRuby::Scrollbar.new(
      content_length: @content_length,
      position: @scroll_position
    )

    # Use a Layout to place scrollbar on the right
    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.percentage(95),
        RatatuiRuby::Constraint.percentage(5),
      ],
      children: [p, s]
    )

    RatatuiRuby.draw(layout)
  end
end

ScrollbarDemo.new.run if __FILE__ == $PROGRAM_NAME
