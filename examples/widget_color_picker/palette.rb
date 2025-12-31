# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "color"

# Holds a primary color and its harmonies.
#
# Color pickers need to show related colors: shades, tints, complements. Building
# these relationships repeatedly is redundant. Passing them individually through
# rendering pipelines is awkward.
#
# This object owns a primary color and generates its harmonies on demand. It
# provides accessor methods and rendering helpers.
#
# Use it to organize color data for palette displays.
#
# === Example
#
#   color = Color.parse("#FF0000")
#   palette = Palette.new(color)
#   palette.main           # => Color
#   palette.all            # => [Harmony, Harmony, ...]
#   blocks = palette.as_blocks(tui)  # => [Block, Block, ...]
class Palette
  def initialize(primary_color)
    @primary = primary_color
  end

  # The primary (main) color, or nil if no color is set.
  #
  # === Example
  #
  #   palette = Palette.new(color)
  #   palette.main.hex  # => "#FF0000"
  def main
    @primary
  end

  # All harmonies: main, shade, tint, complement, split 1, split 2, split-complement.
  #
  # Returns an empty array if no primary color is set.
  #
  # === Example
  #
  #   palette = Palette.new(color)
  #   palette.all.size  # => 7
  def all
    return [] if @primary.nil?

    @primary.harmonies
  end

  # Renders all harmonies as TUI Block widgets.
  #
  # Each harmony becomes a titled block showing its color swatch. Returns an empty
  # array if no primary color is set.
  #
  # [tui] Session or TUI factory object
  #
  # === Example
  #
  #   palette = Palette.new(color)
  #   blocks = palette.as_blocks(tui)
  #   # blocks[0] => Block titled "Main" with color swatch
  def as_blocks(tui)
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
