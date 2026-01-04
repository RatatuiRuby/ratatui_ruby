# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class Event
    class Key < Event
      # Methods and logic for navigation keys.
      module Navigation
        # Returns true if this is a standard key.
        #
        # Standard keys include: characters, Enter, Tab, arrow keys, navigation keys.
        #
        #   event.standard? # => true for "a", "enter", "up", etc.
        def standard?
          @kind == :standard
        end

        # Alias for {#standard?}.
        #
        # Provided for semantic clarity when checking if a key has no special category.
        #
        #   event.unmodified? # => true for standard keys like "a", "enter", "up"
        alias unmodified? standard?

        # Handles navigation-specific DWIM logic for method_missing.
        private def match_navigation_dwim?(key_name, key_sym)
          # DWIM: reverse_tab? matches both BackTab key and Shift+Tab combo
          if key_name == "reverse_tab"
            return true if @code == "back_tab"
            return true if @code == "tab" && @modifiers.include?("shift")
          end

          # DWIM: Check explicit aliases
          navigation_aliases = {
            return: "enter",
            back: "backspace",
            del: "delete",
            ins: "insert",
            pgup: "page_up",
            pageup: "page_up",
            pgdn: "page_down",
            pagedown: "page_down",
          }.freeze

          target_code = navigation_aliases[key_sym]
          return true if target_code && @code == target_code && @modifiers.empty?

          false
        end
      end
    end
  end
end
