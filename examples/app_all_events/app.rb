# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# All Events Demo
# Demonstrates every event type: Key, Mouse, Resize, Paste, Focus.
class AppAllEvents
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
      loop do
        render
        break if handle_input == :quit
        sleep 0.016
      end
    end
  end

  private def render
    RatatuiRuby.draw do |frame|
      border_color = @focused ? "green" : "gray"

      # Set initial resize info from frame dimensions if needed
      if @resize_info == "Resize the terminal..."
        @resize_info = "#{frame.area.width}×#{frame.area.height}"
      end

      # Split into header and content area
      header_area, content_area = RatatuiRuby::Layout.split(
        frame.area,
        direction: :vertical,
        constraints: [
          RatatuiRuby::Constraint.length(1),
          RatatuiRuby::Constraint.fill(1),
        ]
      )

      # Render header
      header = RatatuiRuby::Paragraph.new(
        text: "All Event Types Demo — Press 'q' or Ctrl+C to quit",
        alignment: :center,
        style: RatatuiRuby::Style.new(fg: :cyan, modifiers: [:bold])
      )
      frame.render_widget(header, header_area)

      # Split content area into top and bottom rows
      top_row_area, bottom_row_area = RatatuiRuby::Layout.split(
        content_area,
        direction: :vertical,
        constraints: [
          RatatuiRuby::Constraint.percentage(50),
          RatatuiRuby::Constraint.percentage(50),
        ]
      )

      # Split top row into key and mouse panels
      key_panel_area, mouse_panel_area = RatatuiRuby::Layout.split(
        top_row_area,
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.percentage(50),
          RatatuiRuby::Constraint.percentage(50),
        ]
      )

      # Split bottom row into resize and special panels
      resize_panel_area, special_panel_area = RatatuiRuby::Layout.split(
        bottom_row_area,
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.percentage(50),
          RatatuiRuby::Constraint.percentage(50),
        ]
      )

      # Render key panel
      key_panel = RatatuiRuby::Paragraph.new(
        text: @key_info,
        alignment: :center,
        block: RatatuiRuby::Block.new(
          title: "⌨️  Key Events",
          borders: [:all],
          border_color:
        )
      )
      frame.render_widget(key_panel, key_panel_area)

      # Render mouse panel
      mouse_panel = RatatuiRuby::Paragraph.new(
        text: @mouse_info,
        alignment: :center,
        block: RatatuiRuby::Block.new(
          title: "🖱️  Mouse Events",
          borders: [:all],
          border_color:
        )
      )
      frame.render_widget(mouse_panel, mouse_panel_area)

      # Render resize panel
      resize_panel = RatatuiRuby::Paragraph.new(
        text: @resize_info,
        alignment: :center,
        block: RatatuiRuby::Block.new(
          title: "📐 Resize Events",
          borders: [:all],
          border_color:
        )
      )
      frame.render_widget(resize_panel, resize_panel_area)

      # Render special panel
      special_panel = RatatuiRuby::Paragraph.new(
        text: @special_info,
        alignment: :center,
        block: RatatuiRuby::Block.new(
          title: "✨ Paste & Focus Events",
          borders: [:all],
          border_color:
        )
      )
      frame.render_widget(special_panel, special_panel_area)
    end
  end

  private def handle_input
    event = RatatuiRuby.poll_event

    case event
    # Quit
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
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
      display_content = (content.length > 30) ? "#{content[0..27]}..." : content
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

AppAllEvents.new.run if __FILE__ == $PROGRAM_NAME
