# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
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
    #   if event.resize?
    #     puts "Resized to #{event.width}x#{event.height}"
    #   end
    #
    # Using pattern matching:
    #   case event
    #   in type: :resize, width:, height:
    #     puts "Resized to #{width}x#{height}"
    #   end
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
      #   event.resize? # => true
      #   event.key?    # => false
      #   event.mouse?  # => false
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
      #   case event
      #   in type: :resize, width:, height:
      #     puts "Resized to #{width}x#{height}"
      #   end
      def deconstruct_keys(keys)
        { type: :resize, width: @width, height: @height }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        return false unless other.is_a?(Resize)
        width == other.width && height == other.height
      end
    end
  end
end
