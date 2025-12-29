# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
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
    RatatuiRuby.init_terminal
    begin
      # Capture initial terminal size
      @resize_info = "#{terminal_width}×#{terminal_height}"
      loop do
        render
        break if handle_input == :quit
        sleep 0.016
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

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
    when ->(e) { e == "q" || e == :ctrl_c }
      return :quit

    # Key events
    when ->(e) { e.key? }
      mods = event.modifiers.empty? ? "" : " [#{event.modifiers.join('+')}]"
      @key_info = "Key: #{event.code}#{mods}"

    # Mouse events
    when ->(e) { e.mouse? }
      @mouse_info = "#{event.kind}: #{event.button} at (#{event.x}, #{event.y})"

    # Resize events
    when ->(e) { e.resize? }
      @resize_info = "#{event.width}×#{event.height}"

    # Paste events
    when ->(e) { e.paste? }
      content = event.content.length > 30 ? "#{event.content[0..27]}..." : event.content
      @special_info = "Pasted: #{content.inspect}"

    # Focus events
    when ->(e) { e.focus_gained? }
      @focused = true
      @special_info = "Focus gained! ✓"

    when ->(e) { e.focus_lost? }
      @focused = false
      @special_info = "Focus lost..."
    end

    nil
  end
end

AllEventsApp.new.run if __FILE__ == $PROGRAM_NAME
