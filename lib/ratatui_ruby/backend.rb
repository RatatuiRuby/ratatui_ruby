# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Backend abstractions for terminal rendering.
  #
  # This module contains types related to terminal backend operations.
  # It mirrors upstream Ratatui's <tt>backend</tt> module structure.
  module Backend
    class << self
      # Queries terminal window size in characters and pixels.
      #
      # Some operations need both the character grid and pixel dimensions.
      # Querying them separately wastes syscalls. Most backends fetch both
      # at once anyway.
      #
      # This method queries crossterm for window dimensions. It returns a
      # <tt>Backend::WindowSize</tt> with <tt>columns_rows</tt> and
      # <tt>pixels</tt> fields, each as <tt>Layout::Size</tt> instances.
      # Returns <tt>nil</tt> if the query fails.
      #
      # Note: Pixel dimensions may be zero on some systems. Unix marks
      # these fields "unused" in TIOCGWINSZ. Windows does not implement them.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   ws = RatatuiRuby::Backend.window_size
      #   if ws
      #     puts "#{ws.columns_rows.width}x#{ws.columns_rows.height} chars"
      #     puts "#{ws.pixels.width}x#{ws.pixels.height} pixels"
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def window_size
        window_size = Terminal._terminal_window_size
        return nil unless window_size
        columns, rows, px_width, px_height = window_size
        WindowSize.new(
          columns_rows: Layout::Size.new(width: columns, height: rows),
          pixels: Layout::Size.new(width: px_width, height: px_height)
        )
      rescue
        nil
      end
    end
  end
end

require_relative "backend/window_size"
