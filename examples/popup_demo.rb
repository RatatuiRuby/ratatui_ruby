# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Popup Demo Example
# Demonstrates the Clear widget for creating opaque popups.

class PopupDemo
  def initialize
    @clear_enabled = false
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    end
  end

  private

  def render
    # 1. Background: Loud Red Background
    # This demonstrates "Style Bleed" where the background color persists
    # unless explicitly cleared or overwritten.
    background = RatatuiRuby::Paragraph.new(
      text: "BACKGROUND RED " * 100,
      style: RatatuiRuby::Style.new(bg: :red, fg: :white),
      wrap: true
    )

    # 2. Popup Content: No specific background set (Style.default)
    # Without Clear, this will "inherit" the red background from underneath.
    popup_text = if @clear_enabled
                   "✓ Clear is ENABLED\n\nResets background to default\n(Usually Black/Transparent)\n\nPress Space to toggle"
                 else
                   "✗ Clear is DISABLED\n\nStyle Bleed: Popup is RED!\n(Inherits background style)\n\nPress Space to toggle"
                 end

    popup_content = RatatuiRuby::Paragraph.new(
      text: popup_text,
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "Popup Demo (Press 'q' to quit)",
        borders: [:all]
      )
    )

    # Build the UI with or without Clear
    if @clear_enabled
      # With Clear: Resets the style in the popup area before rendering content
      ui = RatatuiRuby::Overlay.new(
        layers: [
          background,
          RatatuiRuby::Center.new(
            child: RatatuiRuby::Overlay.new(
              layers: [
                RatatuiRuby::Clear.new,
                popup_content
              ]
            ),
            width_percent: 60,
            height_percent: 50
          )
        ]
      )
    else
      # Without Clear: Background style (RED) bleeds through the popup
      ui = RatatuiRuby::Overlay.new(
        layers: [
          background,
          RatatuiRuby::Center.new(
            child: popup_content,
            width_percent: 60,
            height_percent: 50
          )
        ]
      )
    end

    RatatuiRuby.draw(ui)
  end

  def handle_input
    case RatatuiRuby.poll_event
    in type: :key, code: "q" | "c", modifiers: [] | ["ctrl"]
      :quit
    in type: :key, code: " "
      @clear_enabled = !@clear_enabled
    else
      nil
    end
  end
end

PopupDemo.new.run if __FILE__ == $0
