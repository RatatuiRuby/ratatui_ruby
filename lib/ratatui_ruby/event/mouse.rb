# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

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
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2025 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   if event.mouse? && event.down? && event.button == "left"
    #     puts "Left click at #{event.x}, #{event.y}"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
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
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   puts event.button # => "left"
      #
      #--
      # SPDX-SnippetEnd
      #++
      # Can be <tt>nil</tt>, which is treated as <tt>"none"</tt>.
      attr_reader :button
      # List of active modifiers.
      #
      #   puts event.modifiers # => ["ctrl"]
      attr_reader :modifiers

      # Returns true for Mouse events.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   event.mouse?  # => true
      #   event.key?    # => false
      #   event.resize? # => false
      #--
      # SPDX-SnippetEnd
      #++
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

      alias mouse_down? down?
      alias mouse_up? up?

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
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if event.scroll_down?
      #     scroll_offset += 1
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def scroll_down?
        @kind == "scroll_down"
      end

      # Returns true if event involves the left mouse button.
      def left?
        @button == "left"
      end

      # Returns true if event involves the right mouse button.
      def right?
        @button == "right"
      end

      # Returns true if event involves the middle mouse button.
      def middle?
        @button == "middle"
      end

      alias left_button? left?
      alias right_button? right?
      alias middle_button? middle?

      # Deconstructs the event for pattern matching.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   case event
      #   in type: :mouse, kind: "down", x:, y:
      #     puts "Click at #{x}, #{y}"
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def deconstruct_keys(keys)
        { type: :mouse, kind: @kind, x: @x, y: @y, button: @button, modifiers: @modifiers }
      end

      ##
      # Converts the event to a Symbol representation.
      #
      # The format varies by event type:
      #
      # [Left Button]
      #   <tt>:mouse_left_down</tt>, <tt>:mouse_left_up</tt>, <tt>:mouse_left_drag</tt>
      # [Right Button]
      #   <tt>:mouse_right_down</tt>, <tt>:mouse_right_up</tt>, <tt>:mouse_right_drag</tt>
      # [Middle Button]
      #   <tt>:mouse_middle_down</tt>, <tt>:mouse_middle_up</tt>, <tt>:mouse_middle_drag</tt>
      # [Scroll]
      #   <tt>:scroll_up</tt>, <tt>:scroll_down</tt>
      # [Move]
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   <tt>:mouse_moved</tt>
      #
      #--
      # SPDX-SnippetEnd
      #++
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   event = Event::Mouse.new(kind: "down", x: 10, y: 5, button: "left")
      #   event.to_sym  # => :mouse_left_down
      #
      #   scroll = Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none")
      #   scroll.to_sym # => :scroll_up
      #--
      # SPDX-SnippetEnd
      #++
      def to_sym
        if @kind.start_with?("scroll")
          @kind.to_sym
        elsif @button == "none"
          :"mouse_#{@kind}"
        else
          :"mouse_#{@button}_#{@kind}"
        end
      end

      ##
      # Compares the event with another object.
      #
      # - If +other+ is a +Symbol+, compares against #to_sym.
      # - If +other+ is a +Mouse+, compares as a value object.
      # - Otherwise, returns +false+.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if event == :mouse_left_down
      #     handle_click(event)
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def ==(other)
        case other
        when Symbol then to_sym == other
        when Mouse then kind == other.kind && x == other.x && y == other.y && button == other.button && modifiers == other.modifiers
        else false
        end
      end
    end
  end
end
