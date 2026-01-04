# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class Event
    class Key < Event
      # Methods and logic for system and function keys.
      module System
        # Returns true if this is a system key.
        #
        # System keys include: Esc, CapsLock, ScrollLock, NumLock, PrintScreen, Pause, Menu, KeypadBegin.
        #
        #   event.system? # => true for pause, esc, caps_lock, etc.
        def system?
          @kind == :system
        end

        # Returns true if this is a function key (F1-F24).
        #
        #   event.function? # => true for f1, f2, ..., f24
        def function?
          @kind == :function
        end

        # Handles system-specific DWIM logic for method_missing.
        private def match_system_dwim?(key_name, key_sym)
          system_aliases = {
            scrlk: "scroll_lock",
            scroll: "scroll_lock",
            prtsc: "print_screen",
            print: "print_screen",
            escape: "esc",
          }.freeze

          target_code = system_aliases[key_sym]
          return true if target_code && @code == target_code && @modifiers.empty?

          false
        end
      end
    end
  end
end
