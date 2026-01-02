# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Event
    # Reports a mouse interaction.
    #
    # Modern terminals support rich pointer input, but the protocols are complex and varied.
    # Handling clicks, drags, and scrolls requires robust parsing.
    #
    # This event simplifies the complexity. It tells you exactly *what* happened (+kind+),
    # *where* it happened (+x+, +y+), and *which* button was involved.
    #
    # Use this to build interactive UIs. Implement click handlers, draggable sliders, or
    # scrollable viewports with confidence.
    #
    # === Example
    #
    #   if event.mouse? && event.down? && event.button == "left"
    #     puts "Left click at #{event.x}, #{event.y}"
    #   end
    class Mouse < Event
      # The kind of event (<tt>"down"</tt>, <tt>"up"</tt>, <tt>"drag"</tt>, <tt>"moved"</tt>, <tt>"scroll_up"</tt>, <tt>"scroll_down"</tt>).
      #
      #   puts event.kind # => "down"
      attr_reader :kind
      # X coordinate (column).
      #
      #   puts event.x # => 10
      attr_reader :x
      # Y coordinate (row).
      #
      #   puts event.y # => 5
      attr_reader :y
      # The button pressed (<tt>"left"</tt>, <tt>"right"</tt>, <tt>"middle"</tt>, <tt>"none"</tt>).
      #
      #   puts event.button # => "left"
      #
      # Can be <tt>nil</tt>, which is treated as <tt>"none"</tt>.
      attr_reader :button
      # List of active modifiers.
      #
      #   puts event.modifiers # => ["ctrl"]
      attr_reader :modifiers

      # Returns true for Mouse events.
      #
      #   event.mouse?  # => true
      #   event.key?    # => false
      #   event.resize? # => false
      def mouse?
        true
      end

      # Creates a new Mouse event.
      #
      # [kind]
      #   Event kind (String).
      # [x]
      #   X coordinate (Integer).
      # [y]
      #   Y coordinate (Integer).
      # [button]
      #   Button name (String or <tt>nil</tt>).
      # [modifiers]
      #   List of modifiers (Array<String>).
      def initialize(kind:, x:, y:, button:, modifiers: [])
        @kind = kind.freeze
        @x = x
        @y = y
        @button = (button || "none").freeze
        @modifiers = modifiers.map(&:freeze).sort.freeze
      end

      # Returns true if mouse button was pressed down.
      def down?
        @kind == "down"
      end

      # Returns true if mouse button was released.
      def up?
        @kind == "up"
      end

      # Returns true if mouse is being dragged.
      def drag?
        @kind == "drag"
      end

      # Returns true if scroll wheel moved up.
      def scroll_up?
        @kind == "scroll_up"
      end

      # Returns true if scroll wheel moved down.
      #
      #   if event.scroll_down?
      #     scroll_offset += 1
      #   end
      def scroll_down?
        @kind == "scroll_down"
      end

      # Deconstructs the event for pattern matching.
      #
      #   case event
      #   in type: :mouse, kind: "down", x:, y:
      #     puts "Click at #{x}, #{y}"
      #   end
      def deconstruct_keys(keys)
        { type: :mouse, kind: @kind, x: @x, y: @y, button: @button, modifiers: @modifiers }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        return false unless other.is_a?(Mouse)
        kind == other.kind && x == other.x && y == other.y && button == other.button && modifiers == other.modifiers
      end
    end
  end
end
