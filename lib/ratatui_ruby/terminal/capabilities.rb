# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "timeout"

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
      # Checks if stdout connects to a terminal device.
      #
      # Terminal apps render escape sequences. Piped output or log files
      # cannot interpret them. If your app writes ANSI codes to a non-TTY,
      # logs fill with garbage like <tt>[32m</tt> instead of green text.
      #
      # This method checks <tt>$stdout.tty?</tt>. Use it to skip TUI mode
      # when output is redirected. Print plain text instead.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if RatatuiRuby::Terminal.tty?
      #     start_tui
      #   else
      #     print_plain_output
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def tty?
        $stdout.tty?
      end

      # Checks if the terminal declared itself "dumb."
      #
      # Dumb terminals exist. Emacs shell-mode sets <tt>TERM=dumb</tt>.
      # Serial consoles do too. These terminals cannot interpret escape
      # sequences. If your app sends cursor movements or colors, output
      # becomes unreadable.
      #
      # This method checks for explicit <tt>TERM=dumb</tt>. Empty or unset
      # <tt>TERM</tt> means "unknown," not "dumb." Use it to fall back to
      # plain text rendering.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if RatatuiRuby::Terminal.dumb?
      #     render_plain_table(data)
      #   else
      #     render_styled_table(data)
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def dumb?
        ENV["TERM"] == "dumb"
      end

      # Checks if the user disabled color output.
      #
      # Users with visual impairments or screen readers often disable
      # colors. The NO_COLOR standard (no-color.org) provides a universal
      # way to request this. Ignoring it frustrates accessibility-conscious
      # users.
      #
      # This method checks for <tt>NO_COLOR</tt> in the environment. The
      # value does not matter; presence alone disables color. Respect it.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   style = RatatuiRuby::Terminal.no_color? ? :plain : :colored
      #--
      # SPDX-SnippetEnd
      #++
      def no_color?
        ENV.key?("NO_COLOR")
      end

      # Checks if color output is explicitly forced.
      #
      # Some CI systems and logging pipelines detect non-TTY and strip
      # colors. Users want colors anyway for readability. <tt>FORCE_COLOR</tt>
      # overrides the TTY check.
      #
      # This method checks for <tt>FORCE_COLOR</tt> in the environment.
      # When set, your app should emit colors even when <tt>tty?</tt>
      # returns false.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   use_color = RatatuiRuby::Terminal.tty? ||
      #               RatatuiRuby::Terminal.force_color?
      #--
      # SPDX-SnippetEnd
      #++
      def force_color?
        ENV.key?("FORCE_COLOR")
      end

      # Checks if the terminal supports interactive TUI mode.
      #
      # A TUI needs a real terminal. Piped output breaks cursor control.
      # Dumb terminals corrupt escape sequences. Starting TUI mode in
      # these environments wastes resources and confuses users.
      #
      # This method combines <tt>tty?</tt> and <tt>dumb?</tt> checks.
      # Returns +true+ only when both conditions allow TUI operation.
      # Use it as the gatekeeper before calling <tt>run</tt>.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if RatatuiRuby::Terminal.interactive?
      #     RatatuiRuby.run { |tui| main_loop(tui) }
      #   else
      #     abort "Interactive terminal required"
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def interactive?
        tty? && !dumb?
      end

      # Queries how many colors the terminal can display.
      #
      # Modern terminals vary wildly in capability. Some only support 8 ANSI
      # colors. Others display 256. High-end terminals render 16 million
      # truecolor shades. If your app uses rich color palettes without
      # checking, users on basic terminals see garbled output or crashes.
      #
      # This method queries crossterm (which checks <tt>COLORTERM</tt> and
      # <tt>TERM</tt>) and returns the raw count. Use it to select color
      # palettes or degrade gracefully.
      #
      # Returns 8, 256, or 65535 (truecolor).
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   colors = RatatuiRuby::Terminal.available_color_count
      #   palette = colors >= 256 ? :rich : :basic
      #--
      # SPDX-SnippetEnd
      #++
      def available_color_count
        _available_color_count
      end

      # Returns the terminal's color capability as a symbol.
      #
      # Comparing integers is annoying. You want to know: can I use
      # gradients? Do I need a fallback palette? This method translates
      # the raw count into semantic symbols.
      #
      # Returns <tt>:none</tt> when <tt>NO_COLOR</tt> is set or terminal is
      # dumb. Returns <tt>:basic</tt> (8 colors), <tt>:ansi256</tt> (256),
      # or <tt>:truecolor</tt> (16M) based on capability.
      #
      # Use it to switch rendering strategies or skip color entirely.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   case RatatuiRuby::Terminal.color_support
      #   when :truecolor then use_gradient_theme
      #   when :ansi256   then use_256_palette
      #   when :basic     then use_ansi_colors
      #   when :none      then use_monochrome
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def color_support
        return :none if no_color?
        return :none if dumb?

        count = available_color_count
        return :truecolor if count >= 65_535
        return :ansi256 if count >= 256

        :basic
      end

      # Checks for Kitty keyboard protocol support.
      #
      # Standard terminal input is ambiguous. Escape key and arrow keys
      # share prefixes. Modifier keys get lost. Applications that need
      # precise key handling (editors, games) struggle with the limitations.
      #
      # The Kitty keyboard protocol solves this. Terminals that support it
      # report key presses unambiguously, with full modifier information.
      # This method queries support so you can enable enhanced input or
      # fall back gracefully.
      #
      # Returns <tt>false</tt> immediately if <tt>tty?</tt> returns false.
      # Otherwise queries crossterm with a 0.5s timeout.
      # Returns <tt>true</tt> only if the terminal responds affirmatively.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if RatatuiRuby::Terminal.supports_keyboard_enhancement?
      #     enable_vim_style_keybindings
      #   else
      #     use_simple_navigation
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def supports_keyboard_enhancement?
        return false unless tty?

        Timeout.timeout(0.5) { _supports_keyboard_enhancement }
      rescue
        false
      end
    end

    extend Capabilities
  end
end
