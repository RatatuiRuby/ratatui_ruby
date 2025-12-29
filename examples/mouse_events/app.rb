# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class MouseEventsApp
  def initialize
    @message = "Waiting for Mouse... (q to quit)"
    @details = ""
    @color = "white"
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

    case event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      return :quit
    in type: :mouse, kind:, button:, x:, y:, modifiers:
      @color = "green"
      case kind
      when "down"
        @message = "#{button.capitalize} Click at [#{x}, #{y}]"
        @details = "Modifiers: #{modifiers.join(', ')}"
      when "up"
        @message = "#{button.capitalize} Release at [#{x}, #{y}]"
        @details = "Modifiers: #{modifiers.join(', ')}"
      when "drag"
        @message = "Dragging #{button.capitalize} Button at [#{x}, #{y}]"
        @details = "Modifiers: #{modifiers.join(', ')}"
      when "moved"
        @message = "Mouse Moved to [#{x}, #{y}]"
        @details = "Modifiers: #{modifiers.join(', ')}"
      when "scroll_down"
        @message = "Scrolled Down"
        @details = "Position: [#{x}, #{y}]"
      when "scroll_up"
        @message = "Scrolled Up"
        @details = "Position: [#{x}, #{y}]"
      else
        nil
      end
    else
      nil
    end
    nil
  end
end

MouseEventsApp.new.run if __FILE__ == $0
