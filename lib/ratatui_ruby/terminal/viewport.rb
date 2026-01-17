# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  ##
  # Terminal configuration and viewport settings.
  #
  # Your app needs to choose how it occupies the terminal.
  # Fullscreen apps take over the whole screen and clear on exit.
  # Inline apps run in a fixed region and persist in scrollback.
  # Configuring this manually is error-prone.
  #
  # This module handles the choice. It defines viewport modes and their parameters.
  #
  # @see Terminal::Viewport
  class Terminal
    ##
    # Viewport configuration for terminal initialization.
    #
    # Determines how RatatuiRuby interacts with the terminal:
    # - **Fullscreen**: Uses alternate screen, clears on exit (default)
    # - **Inline**: Fixed-height region, persists in scrollback after exit
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Fullscreen (default behavior)
    #   RatatuiRuby.run { |tui| ... }
    #
    #   # Inline with 8 lines
    #   RatatuiRuby.run(viewport: :inline, height: 8) { |tui| ... }
    #--
    # SPDX-SnippetEnd
    #++
    class Viewport < Data.define(:type, :height)
      ##
      # Creates a fullscreen viewport (alternate screen).
      def self.fullscreen
        new(type: :fullscreen)
      end

      ##
      # Creates an inline viewport with the given height.
      def self.inline(height)
        new(type: :inline, height:)
      end

      ##
      # Creates a new viewport configuration.
      #
      # [type] Symbol representing viewport type (:fullscreen or :inline).
      # [height] Integer height in lines (required for :inline, ignored for :fullscreen).
      #
      # Most developers use {.fullscreen} or {.inline} factory methods instead.
      def initialize(type:, height: nil)
        super
      end

      ##
      # Returns true if this is a fullscreen viewport.
      def fullscreen?
        type == :fullscreen
      end

      ##
      # Returns true if this is an inline viewport.
      def inline?
        type == :inline
      end
    end
  end
end
