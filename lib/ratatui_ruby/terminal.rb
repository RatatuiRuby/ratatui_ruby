# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Terminal object for managing terminal lifecycle and rendering.
  #
  # Instance-based API aligned with upstream Ratatui Terminal struct.
  #
  # === Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   terminal = RatatuiRuby::Terminal.new
  #   terminal.draw { |frame| ... }
  #   terminal.restore
  #--
  # SPDX-SnippetEnd
  #++
  class Terminal
    ##
    # :attr_reader: terminal_id
    # Unique identifier for this terminal instance in Rust (Integer).
    attr_reader :terminal_id

    # Creates a new Terminal instance.
    #
    # [viewport] Symbol or Viewport object (:fullscreen or :inline)
    # [height] Integer height for inline viewports
    def initialize(viewport: :fullscreen, height: nil)
      @viewport = resolve_viewport(viewport, height)

      # Call Rust FFI to create instance and get ID
      # For now, only test backend is supported (real crossterm coming later)
      @terminal_id = self.class._init_test_terminal_instance(
        80, # default width for test
        24, # default height for test
        @viewport.type.to_s,
        @viewport.height
      )
    end

    # Returns the terminal size as a Layout::Rect
    # Rust constructs the Rect object directly (not a hash!)
    def size
      self.class._get_terminal_size_instance(@terminal_id)
    end

    private def resolve_viewport(viewport, height)
      case viewport
      when nil, :fullscreen then Terminal::Viewport.fullscreen
      when :inline then Terminal::Viewport.inline(height || 8)
      when Terminal::Viewport then viewport
      else raise ArgumentError, "Unknown viewport: #{viewport.inspect}"
      end
    end
  end
end
