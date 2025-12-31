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
    RatatuiRuby.run do |tui|
      loop do
        tui.draw do |frame|
          render(tui, frame)
        end
        break if handle_input(tui) == :quit
      end
    end
  end

  private def render(tui, frame)
    # Create a centered block with the mouse event details
    block = tui.block(
      title: "Mouse Event Plumbing",
      borders: [:all],
      border_type: :rounded,
      border_style: tui.style(fg: @color)
    )

    content = tui.paragraph(
      text: "#{@message}\n#{@details}",
      alignment: :center,
      block:
    )

    # Use a layout to center the content
    _top, center, _bottom = tui.layout_split(
      frame.area,
      direction: :vertical,
      constraints: [
        tui.constraint_percentage(25),
        tui.constraint_percentage(50),
        tui.constraint_percentage(25),
      ]
    )

    frame.render_widget(tui.paragraph(text: ""), frame.area)
    frame.render_widget(content, center)
  end

  private def handle_input(tui)
    event = tui.poll_event
    return unless event

    case event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
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
