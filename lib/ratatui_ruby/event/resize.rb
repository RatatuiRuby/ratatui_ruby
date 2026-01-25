# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class Event
    # Signals a change in terminal dimensions.
    #
    # The terminal window is dynamic, not static. The user changes its dimensions at will,
    # usually breaking a fixed layout.
    #
    # This event captures the new state. It delivers the updated +width+ and +height+
    # immediately after the change.
    #
    # Use these dimensions to drive your layout logic. Recalculate constraints. Reallocate space.
    # Fill the new canvas completely to maintain a responsive design.
    #
    # === Examples
    #
    # Using predicates:
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2025 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   if event.resize?
    #     puts "Resized to #{event.width}x#{event.height}"
    #   end
    #
    #--
    # SPDX-SnippetEnd
    #++
    # Using pattern matching:
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2025 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   case event
    #   in type: :resize, width:, height:
    #     puts "Resized to #{width}x#{height}"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    class Resize < Event
      # New terminal width in columns.
      #
      #   puts event.width # => 80
      attr_reader :width

      # New terminal height in rows.
      #
      #   puts event.height # => 24
      attr_reader :height

      # Returns true for Resize events.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   event.resize? # => true
      #   event.key?    # => false
      #   event.mouse?  # => false
      #--
      # SPDX-SnippetEnd
      #++
      def resize?
        true
      end

      # Creates a new Resize event.
      #
      # [width]
      #   New width (Integer).
      # [height]
      #   New height (Integer).
      def initialize(width:, height:)
        @width = width
        @height = height
      end

      # Deconstructs the event for pattern matching.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   case event
      #   in type: :resize, width:, height:
      #     puts "Resized to #{width}x#{height}"
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def deconstruct_keys(keys)
        { type: :resize, width: @width, height: @height }
      end

      ##
      # Converts the event to a Symbol representation.
      #
      # Always returns <tt>:resize</tt>.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   event = Event::Resize.new(width: 80, height: 24)
      #   event.to_sym # => :resize
      #--
      # SPDX-SnippetEnd
      #++
      def to_sym
        :resize
      end

      ##
      # Compares the event with another object.
      #
      # - If +other+ is a +Symbol+, compares against #to_sym.
      # - If +other+ is a +Resize+, compares as a value object.
      # - Otherwise, returns +false+.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   if event == :resize
      #     handle_resize(event)
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def ==(other)
        case other
        when Symbol then to_sym == other
        when Resize then width == other.width && height == other.height
        else false
        end
      end
    end
  end
end
