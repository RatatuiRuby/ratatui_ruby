# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

class MouseEventsApp
  def initialize
    @message = "Waiting for Mouse... (q to quit)"
    @details = ""
    @color = "white"
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  def render
    # Create a centered block with the mouse event details
    block = RatatuiRuby::Block.new(
      title: "Mouse Event Plumbing",
      borders: [:all],
      border_color: @color
    )

    content = RatatuiRuby::Paragraph.new(
      text: "#{@message}\n#{@details}",
      align: :center,
      block:
    )

    # Use a layout to center the content
    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.percentage(25),
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(25),
      ],
      children: [
        RatatuiRuby::Paragraph.new(text: ""),
        content,
        RatatuiRuby::Paragraph.new(text: ""),
      ]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    if event[:type] == :key && event[:code] == "q"
      return :quit
    end

    if event[:type] == :mouse
      @color = "green"
      case event[:kind]
      when :down
        @message = "#{event[:button].to_s.capitalize} Click at [#{event[:x]}, #{event[:y]}]"
        @details = "Modifiers: #{event[:modifiers].join(', ')}"
      when :up
        @message = "#{event[:button].to_s.capitalize} Release at [#{event[:x]}, #{event[:y]}]"
        @details = "Modifiers: #{event[:modifiers].join(', ')}"
      when :drag
        @message = "Dragging #{event[:button].to_s.capitalize} Button at [#{event[:x]}, #{event[:y]}]"
        @details = "Modifiers: #{event[:modifiers].join(', ')}"
      when :moved
        @message = "Mouse Moved to [#{event[:x]}, #{event[:y]}]"
        @details = "Modifiers: #{event[:modifiers].join(', ')}"
      when :scroll_down
        @message = "Scrolled Down"
        @details = "Position: [#{event[:x]}, #{event[:y]}]"
      when :scroll_up
        @message = "Scrolled Up"
        @details = "Position: [#{event[:x]}, #{event[:y]}]"
      end
    end
    nil
  end
end

MouseEventsApp.new.run if __FILE__ == $0
