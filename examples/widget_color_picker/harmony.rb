# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# A single color variant with label and styling information.
#
# Color palettes need to show individual colors with labels (Main, Shade, Tint,
# Complement). Bundling a color's hex code, text color, and frame color together
# is natural—they're always used as a set.
#
# This value object pairs a color with its metadata and rendering styles.
#
# Use it to represent colors in a palette or harmony.
#
# === Attributes
#
# [label] String label for this color variant
# [hex] String hex color code
# [text_color] Symbol (:white or :black) for readable text
# [frame_color] String background color for the swatch frame
#
# === Example
#
#   harmony = Harmony.new(
#     label: "Main",
#     hex: "#FF0000",
#     text_color: :white,
#     frame_color: "#000000"
#   )
Harmony = Data.define(:label, :hex, :text_color, :frame_color) do
  # Renders a 4-line color swatch for display in a TUI Block.
  #
  # Produces a visual representation: a 7-character-wide box with the color
  # centered and the hex code below.
  #
  # [tui] Session or TUI factory object
  #
  # === Example
  #
  #   harmony = Harmony.new(...)
  #   lines = harmony.color_swatch_lines(tui)
  #   # => [TextLine, TextLine, TextLine, TextLine]
  def color_swatch_lines(tui)
    [
      tui.text_line(spans: Array.new(7) { tui.text_span(content: " ", style: tui.style(bg: frame_color)) }),
      tui.text_line(spans: [
        *Array.new(3) { tui.text_span(content: " ", style: tui.style(bg: frame_color)) },
        tui.text_span(content: " ", style: tui.style(bg: hex, fg: text_color)),
        *Array.new(3) { tui.text_span(content: " ", style: tui.style(bg: frame_color)) },
      ]),
      tui.text_line(spans: Array.new(7) { tui.text_span(content: " ", style: tui.style(bg: frame_color)) }),
      tui.text_line(spans: [tui.text_span(content: hex, style: tui.style(fg: :white))]),
    ]
  end
end
