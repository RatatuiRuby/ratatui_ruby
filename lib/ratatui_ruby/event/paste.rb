# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
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
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2025 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   if event.paste?
    #     puts "Pasted: #{event.content}"
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
    #   in type: :paste, content:
    #     puts "Pasted: #{content}"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    class Paste < Event
      # The pasted content.
      #
      #   puts event.content # => "https://example.com"
      attr_reader :content

      # Returns true for Paste events.
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   event.paste?  # => true
      #   event.key?    # => false
      #   event.resize? # => false
      #--
      # SPDX-SnippetEnd
      #++
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
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2025 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   case event
      #   in type: :paste, content:
      #     puts "User pasted: #{content}"
      #   end
      #--
      # SPDX-SnippetEnd
      #++
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
