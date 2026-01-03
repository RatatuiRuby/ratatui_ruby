# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Event
    class Key < Event
      # Methods and logic for modifier keys.
      module Modifier
        # Returns true if CTRL is held OR if this is a left_control/right_control key event.
        def ctrl?
          @modifiers.include?("ctrl") || @code == "left_control" || @code == "right_control"
        end

        # Alias for {#ctrl?}.
        alias control? ctrl?

        # Returns true if ALT is held OR if this is a left_alt/right_alt key event.
        def alt?
          @modifiers.include?("alt") || @code == "left_alt" || @code == "right_alt"
        end

        # Alias for {#alt?}.
        alias option? alt?

        # Returns true if SHIFT is held OR if this is a left_shift/right_shift key event.
        def shift?
          @modifiers.include?("shift") || @code == "left_shift" || @code == "right_shift"
        end

        # Returns true if SUPER is held OR if this is a left_super/right_super key event.
        # Also responds to platform aliases: win?, command?, cmd?, tux?
        def super?
          @modifiers.include?("super") || @code == "left_super" || @code == "right_super"
        end

        # Alias for {#super?}.
        alias win? super?
        # Alias for {#super?}.
        alias command? super?
        # Alias for {#super?}.
        alias cmd? super?
        # Alias for {#super?}.
        alias tux? super?

        # Returns true if HYPER is held OR if this is a left_hyper/right_hyper key event.
        def hyper?
          @modifiers.include?("hyper") || @code == "left_hyper" || @code == "right_hyper"
        end

        # Returns true if META is held OR if this is a left_meta/right_meta key event.
        def meta?
          @modifiers.include?("meta") || @code == "left_meta" || @code == "right_meta"
        end

        # Returns true if this is a modifier key event.
        #
        # Some applications need to know if an event represents a generic key
        # press or a specific modifier key (like CTRL or ALT) being pressed on
        # its own.
        #
        # This method identifies if the key event itself is a modifier key.
        #
        # === Example
        #
        #   if event.modifier?
        #     # Handle solo modifier key press
        #   end
        def modifier?
          @kind == :modifier
        end

        # Handles modifier-specific DWIM logic for method_missing.
        private def match_modifier_dwim?(key_name, key_sym)
          # Platform modifier aliases
          modifier_aliases = {
            win: "super",
            command: "super",
            cmd: "super",
            tux: "super",
          }.freeze

          target_modifier = modifier_aliases[key_sym]
          if target_modifier
            return true if @modifiers.include?(target_modifier)
            return true if @code == "left_#{target_modifier}" || @code == "right_#{target_modifier}"
          end

          false
        end
      end
    end
  end
end
