# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Backend
    # Terminal window dimensions in characters and pixels.
    #
    # Some operations need both character grid size and pixel dimensions.
    # Sixel graphics, image rendering, and precise layout calculations all
    # benefit from knowing both measurements at once.
    #
    # This struct bundles both sizes together. It matches upstream Ratatui's
    # <tt>backend::WindowSize</tt> struct exactly.
    #
    # Both fields are <tt>Layout::Size</tt> instances. This reuses the same
    # type for character and pixel dimensions, matching upstream design.
    #
    # Note: Pixel dimensions may be zero on some systems. Unix marks these
    # fields "unused" in TIOCGWINSZ. Windows does not implement them.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   ws = RatatuiRuby::Terminal.window_size
    #   if ws
    #     puts "#{ws.columns_rows.width}x#{ws.columns_rows.height} chars"
    #     puts "#{ws.pixels.width}x#{ws.pixels.height} pixels"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    class WindowSize < Data.define(:columns_rows, :pixels)
      ##
      # :attr_reader: columns_rows
      # Size of the window in characters (columns/rows) as <tt>Layout::Size</tt>.

      ##
      # :attr_reader: pixels
      # Size of the window in pixels as <tt>Layout::Size</tt>.
    end
  end
end
