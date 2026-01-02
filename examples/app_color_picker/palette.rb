# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "color"

# A self-contained component displaying a color palette with harmonies.
#
# Color pickers need to show related colors: shades, tints, complements. This
# component owns a primary color and renders its harmonies.
#
# === Component Contract
#
# - `render(tui, frame, area)`: Draws the harmony blocks; stores `area`
# - `handle_event(event) -> nil`: Display-only, always returns nil
# - `update_color(color)`: Updates the primary color (called by MainContainer)
#
# === Example
#
#   palette = Palette.new
#   palette.update_color(Color.parse("#FF0000"))
#   palette.render(tui, frame, palette_area)
class Palette
  def initialize(primary_color = nil)
    @primary = primary_color
    @area = nil
  end

  # The cached render area.
  attr_reader :area

  # The primary (main) color, or nil if no color is set.
  #
  # === Example
  #
  #   palette.main.hex  # => "#FF0000"
  def main
    @primary
  end

  # Updates the primary color.
  #
  # Called by the MainContainer when Input submits a new color.
  #
  # [color] Color object or nil
  def update_color(color)
    @primary = color
  end

  # All harmonies: main, shade, tint, complement, split 1, split 2, split-complement.
  #
  # Returns an empty array if no primary color is set.
  def all
    return [] if @primary.nil?

    @primary.harmonies
  end

  # Renders the palette into the given area.
  #
  # Shows all harmony blocks in a horizontal layout. If no color is set,
  # displays a placeholder message.
  #
  # [tui] Session or TUI factory object
  # [frame] Frame object from RatatuiRuby.draw block
  # [area] Rect area to draw into
  #
  # === Example
  #
  #   palette.render(tui, frame, palette_area)
  def render(tui, frame, area)
    @area = area
    widget = build_widget(tui)
    frame.render_widget(widget, area)
  end

  # Display-only component; always returns nil.
  def handle_event(_event)
    nil
  end

  private def build_widget(tui)
    if @primary.nil?
      tui.paragraph(text: "No color selected")
    else
      blocks = as_blocks(tui)
      tui.layout(
        direction: :horizontal,
        constraints: Array.new(blocks.size) { tui.constraint_fill(1) },
        children: blocks
      )
    end
  end

  private def as_blocks(tui)
    return [] if @primary.nil?

    all.map do |harmony|
      tui.block(
        title: harmony.label,
        borders: [:all],
        children: [
          tui.paragraph(text: harmony.color_swatch_lines(tui)),
        ]
      )
    end
  end
end
