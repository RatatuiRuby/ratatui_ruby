# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class Terminal
    # Environment-based terminal capability detection.
    #
    # TUI applications need to know what the terminal supports. Color depth
    # varies. Some terminals lack escape sequence support entirely. Users
    # set environment variables like <tt>NO_COLOR</tt> to express preferences.
    #
    # This module detects terminal capabilities from environment variables.
    # It checks <tt>TERM</tt>, <tt>COLORTERM</tt>, <tt>NO_COLOR</tt>, and
    # <tt>FORCE_COLOR</tt> to determine what the terminal supports.
    #
    # Use these methods before initializing a Terminal instance to decide
    # whether TUI mode is appropriate for the current environment.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   if RatatuiRuby::Terminal.interactive?
    #     RatatuiRuby.run { |tui| ... }
    #   else
    #     puts "TUI mode not available"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    module Capabilities
      # Checks if stdout connects to a terminal.
      #
      # Returns <tt>true</tt> if stdout is a TTY. Piped output or redirected
      # files return <tt>false</tt>.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   RatatuiRuby::Terminal.tty?  # => true (in a terminal)
      #--
      # SPDX-SnippetEnd
      #++
      def tty?
        $stdout.tty?
      end

      # Checks if this is a dumb terminal.
      #
      # Returns <tt>true</tt> if <tt>TERM</tt> is "dumb" or empty/unset.
      # Dumb terminals do not support escape sequences.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   ENV["TERM"] = "dumb"
      #   RatatuiRuby::Terminal.dumb?  # => true
      #--
      # SPDX-SnippetEnd
      #++
      def dumb?
        term = ENV["TERM"].to_s
        term.empty? || term == "dumb"
      end

      # Checks if color output is disabled.
      #
      # Returns <tt>true</tt> if the <tt>NO_COLOR</tt> environment variable
      # is set. Respects the NO_COLOR standard (https://no-color.org/).
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   ENV["NO_COLOR"] = "1"
      #   RatatuiRuby::Terminal.no_color?  # => true
      #--
      # SPDX-SnippetEnd
      #++
      def no_color?
        ENV.key?("NO_COLOR")
      end

      # Checks if color output is forced.
      #
      # Returns <tt>true</tt> if the <tt>FORCE_COLOR</tt> environment variable
      # is set. Overrides <tt>tty?</tt> check to enable colors in piped output.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   ENV["FORCE_COLOR"] = "1"
      #   RatatuiRuby::Terminal.force_color?  # => true
      #--
      # SPDX-SnippetEnd
      #++
      def force_color?
        ENV.key?("FORCE_COLOR")
      end

      # Checks if the terminal is interactive.
      #
      # Returns <tt>false</tt> for dumb terminals or piped output.
      # Use this to decide whether to enter fullscreen TUI mode.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if RatatuiRuby::Terminal.interactive?
      #     RatatuiRuby.run { |tui| ... }
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def interactive?
        tty? && !dumb?
      end
    end

    extend Capabilities
  end
end
