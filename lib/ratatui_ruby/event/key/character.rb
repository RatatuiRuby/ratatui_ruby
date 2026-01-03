# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Event
    class Key < Event
      # Methods for handling printable characters.
      module Character
        # Returns true if the key represents a single printable character.
        #
        #   RatatuiRuby::Event::Key.new(code: "a").text?       # => true
        #   RatatuiRuby::Event::Key.new(code: "enter").text?   # => false
        #   RatatuiRuby::Event::Key.new(code: "space").text?   # => false ("space" is not 1 char, " " is)
        def text?
          @code.length == 1
        end

        # Returns the key as a printable character (if applicable).
        #
        # [Printable Characters]
        #   Returns the character itself (e.g., <tt>"a"</tt>, <tt>"1"</tt>, <tt>" "</tt>).
        # [Special Keys]
        #   Returns <tt>nil</tt> (e.g., <tt>"enter"</tt>, <tt>"up"</tt>, <tt>"f1"</tt>).
        #
        #   RatatuiRuby::Event::Key.new(code: "a").char      # => "a"
        #   RatatuiRuby::Event::Key.new(code: "enter").char  # => nil
        def char
          text? ? @code : nil
        end
      end
    end
  end
end
