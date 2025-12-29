# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# All Events Demo
# Demonstrates every event type: Key, Mouse, Resize, Paste, Focus.
class AllEventsApp
  attr_reader :key_info, :mouse_info, :resize_info, :special_info, :focused

  def initialize
    @key_info = "Press any key..."
    @mouse_info = "Click or scroll..."
    @resize_info = "Resize the terminal..."
    @special_info = "Paste text or change focus..."
    @focused = true
  end

  def run
    RatatuiRuby.run do
      # Capture initial terminal size
      @resize_info = "#{terminal_width}×#{terminal_height}"
      loop do
        render
        break if handle_input == :quit
        sleep 0.016
      end
    end
  end

  private

  def terminal_width
    80 # Approximation; actual size comes from Resize events
  end

  def terminal_height
    24
  end

  def render
    border_color = @focused ? "green" : "gray"

    key_panel = RatatuiRuby::Paragraph.new(
      text: @key_info,
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "⌨️  Key Events",
        borders: [:all],
        border_color: border_color
      )
    )

    mouse_panel = RatatuiRuby::Paragraph.new(
      text: @mouse_info,
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "🖱️  Mouse Events",
        borders: [:all],
        border_color: border_color
      )
    )

    resize_panel = RatatuiRuby::Paragraph.new(
      text: @resize_info,
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "📐 Resize Events",
        borders: [:all],
        border_color: border_color
      )
    )

    special_panel = RatatuiRuby::Paragraph.new(
      text: @special_info,
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "✨ Paste & Focus Events",
        borders: [:all],
        border_color: border_color
      )
    )

    # 2x2 grid layout
    top_row = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(50)
      ],
      children: [key_panel, mouse_panel]
    )

    bottom_row = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(50)
      ],
      children: [resize_panel, special_panel]
    )

    # Header with instructions
    header = RatatuiRuby::Paragraph.new(
      text: "All Event Types Demo — Press 'q' or Ctrl+C to quit",
      align: :center,
      style: { fg: :cyan, modifiers: [:bold] }
    )

    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(1),
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(50)
      ],
      children: [header, top_row, bottom_row]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    # Quit
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      return :quit

    # Key events
    in type: :key, code:, modifiers:
      mods = modifiers.empty? ? "" : " [#{modifiers.join('+')}]"
      @key_info = "Key: #{code}#{mods}"

    # Mouse events
    in type: :mouse, kind:, button:, x:, y:
      @mouse_info = "#{kind}: #{button} at (#{x}, #{y})"

    # Resize events
    in type: :resize, width:, height:
      @resize_info = "#{width}×#{height}"

    # Paste events
    in type: :paste, content:
      display_content = content.length > 30 ? "#{content[0..27]}..." : content
      @special_info = "Pasted: #{display_content.inspect}"

    # Focus events
    in type: :focus_gained
      @focused = true
      @special_info = "Focus gained! ✓"

    in type: :focus_lost
      @focused = false
      @special_info = "Focus lost..."
    else
      nil
    end

    nil
  end
end

AllEventsApp.new.run if __FILE__ == $PROGRAM_NAME
