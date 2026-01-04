# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class Event
    # Encapsulates pasted text.
    #
    # Users frequently paste text into terminals. Without specific handling, a paste appears as
    # a flood of rapid keystrokes, often triggering accidental commands or confusing the input state.
    #
    # This event makes pasting safe. It groups the entire inserted block into a single atomic action.
    #
    # Handle this event to support bulk text insertion cleanly. Insert the +content+ directly into
    # your field or buffer without triggering per-character logic.
    #
    # === Examples
    #
    # Using predicates:
    #   if event.paste?
    #     puts "Pasted: #{event.content}"
    #   end
    #
    # Using pattern matching:
    #   case event
    #   in type: :paste, content:
    #     puts "Pasted: #{content}"
    #   end
    class Paste < Event
      # The pasted content.
      #
      #   puts event.content # => "https://example.com"
      attr_reader :content

      # Returns true for Paste events.
      #
      #   event.paste?  # => true
      #   event.key?    # => false
      #   event.resize? # => false
      def paste?
        true
      end

      # Creates a new Paste event.
      #
      # [content]
      #   Pasted text (String).
      def initialize(content:)
        @content = content.freeze
      end

      # Deconstructs the event for pattern matching.
      #
      #   case event
      #   in type: :paste, content:
      #     puts "User pasted: #{content}"
      #   end
      def deconstruct_keys(keys)
        { type: :paste, content: @content }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        return false unless other.is_a?(Paste)
        content == other.content
      end
    end
  end
end
