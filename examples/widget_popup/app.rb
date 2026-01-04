# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Popup Example
# Demonstrates the Clear widget for creating opaque popups.

class WidgetPopup
  def initialize
    @clear_enabled = false
  end

  def run
    RatatuiRuby.run do |tui|
      loop do
        tui.draw do |frame|
          render(tui, frame)
        end
        break if handle_input(tui) == :quit
        sleep 0.05
      end
    end
  end

  private def render(tui, frame)
    area = frame.area

    # 1. Background: Loud Red Background
    # This demonstrates "Style Bleed" where the background color persists
    # unless explicitly cleared or overwritten.
    background = tui.paragraph(
      text: "BACKGROUND RED " * 100,
      style: tui.style(bg: :red, fg: :white),
      wrap: true
    )
    frame.render_widget(background, area)

    # 2. Popup Area Calculation
    # Center the popup vertically and horizontally
    vertical_layout = tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        tui.constraint_percentage(25),
        tui.constraint_percentage(50), # 50% height
        tui.constraint_percentage(25),
      ]
    )
    popup_area_vertical = vertical_layout[1]

    horizontal_layout = tui.layout_split(
      popup_area_vertical,
      direction: :horizontal,
      constraints: [
        tui.constraint_percentage(20),
        tui.constraint_percentage(60), # 60% width
        tui.constraint_percentage(20),
      ]
    )
    popup_area = horizontal_layout[1]

    # 3. Popup Content
    # Without Clear, this will "inherit" the red background from underneath.
    popup_text = if @clear_enabled
      "✓ Clear is ENABLED\n\nResets background to default\n(Usually Black/Transparent)\n\nPress Space to toggle"
    else
      "✗ Clear is DISABLED\n\nStyle Bleed: Popup is RED!\n(Inherits background style)\n\nPress Space to toggle"
    end

    popup_content = tui.paragraph(
      text: popup_text,
      alignment: :center,
      block: tui.block(
        title: "Popup (q to quit, space to toggle)",
        borders: [:all]
      )
    )

    # 4. Render Popup
    if @clear_enabled
      # With Clear: Resets the style in the popup area before rendering content
      frame.render_widget(tui.clear, popup_area)
    end

    frame.render_widget(popup_content, popup_area)
  end

  private def handle_input(tui)
    case tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: " "
      @clear_enabled = !@clear_enabled
    else
      nil
    end
  end
end

WidgetPopup.new.run if __FILE__ == $0
