# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Event
    # Captures a keyboard interaction.
    #
    # The keyboard is the primary interface for your terminal application. Raw key codes are often cryptic,
    # and handling modifiers manually is error-prone.
    #
    # This event creates clarity. It encapsulates the interaction, providing a normalized +code+ and
    # a list of active +modifiers+.
    #
    # Compare it directly to strings or symbols for rapid development, or use pattern matching for
    # complex control schemes.
    #
    # === Examples
    #
    # Using predicates:
    #   if event.key? && event.ctrl? && event.code == "c"
    #     exit
    #   end
    #
    # Using symbol comparison:
    #   if event == :ctrl_c
    #     exit
    #   end
    #
    # Using pattern matching:
    #   case event
    #   in type: :key, code: "c", modifiers: ["ctrl"]
    #     exit
    #   end
    class Key < Event
      # The key code (e.g., <tt>"a"</tt>, <tt>"enter"</tt>, <tt>"up"</tt>).
      #
      #   puts event.code # => "enter"
      attr_reader :code

      # List of active modifiers (<tt>"ctrl"</tt>, <tt>"alt"</tt>, <tt>"shift"</tt>).
      #
      #   puts event.modifiers # => ["ctrl", "shift"]
      attr_reader :modifiers

      # Returns true for Key events.
      #
      #   event.key?    # => true
      #   event.mouse?  # => false
      #   event.resize? # => false
      def key?
        true
      end

      # Creates a new Key event.
      #
      # [code]
      #   The key code (String).
      # [modifiers]
      #   List of modifiers (Array<String>).
      def initialize(code:, modifiers: [])
        @code = code
        @modifiers = modifiers.sort
      end

      # Compares the event with another object.
      #
      # - If +other+ is a +Symbol+, compares against #to_sym.
      # - If +other+ is a +String+, compares against #to_s.
      # - Otherwise, performs standard equality check.
      # - Otherwise, compares internal state (code + modifiers).
      def ==(other)
        case other
        when Symbol
          to_sym == other
        when String
          to_s == other
        when Key
          code == other.code && modifiers == other.modifiers
        else
          super
        end
      end

      # Converts the event to a Symbol representation.
      #
      # The format is <tt>[modifiers_]code</tt>. Modifiers are sorted alphabetically (alt, ctrl, shift)
      # and joined by underscores.
      #
      # === Supported Keys
      #
      # [Standard]
      #   <tt>:enter</tt>, <tt>:backspace</tt>, <tt>:tab</tt>, <tt>:esc</tt>, <tt>:page_up</tt>, <tt>:page_down</tt>, <tt>:home</tt>, <tt>:end</tt>, <tt>:delete</tt>, <tt>:insert</tt>, <tt>:f1</tt>..<tt>:f12</tt>
      # [Navigation]
      #   <tt>:up</tt>, <tt>:down</tt>, <tt>:left</tt>, <tt>:right</tt>
      # [Characters]
      #   <tt>:a</tt>, <tt>:b</tt>, <tt>:1</tt>, <tt>:space</tt>, etc.
      #
      # === Modifier Examples
      #
      # * <tt>:ctrl_c</tt>
      # * <tt>:alt_enter</tt>
      # * <tt>:shift_left</tt>
      # * <tt>:ctrl_alt_delete</tt>
      def to_sym
        mods = @modifiers.join("_")
        if mods.empty?
          @code.to_sym
        else
          :"#{mods}_#{@code}"
        end
      end

      # Converts the event to its String representation.
      #
      # [Printable Characters]
      #   Returns the character itself (e.g., <tt>"a"</tt>, <tt>"1"</tt>, <tt>" "</tt>).
      # [Special Keys]
      #   Returns an empty string (e.g., <tt>"enter"</tt>, <tt>"up"</tt>, <tt>"f1"</tt> all return <tt>""</tt>).
      # [Modifiers]
      #   Returns the character if printable, ignoring modifiers unless they alter the character code itself.
      #   Note that <tt>ctrl+c</tt> typically returns <tt>"c"</tt> as the code, so +to_s+ will return <tt>"c"</tt>.
      def to_s
        if text?
          @code
        else
          ""
        end
      end

      # Returns inspection string.
      def inspect
        "#<#{self.class} code=#{@code.inspect} modifiers=#{@modifiers.inspect}>"
      end

      # Returns true if CTRL is held.
      def ctrl?
        @modifiers.include?("ctrl")
      end

      # Returns true if ALT is held.
      def alt?
        @modifiers.include?("alt")
      end

      # Returns true if SHIFT is held.
      def shift?
        @modifiers.include?("shift")
      end

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
      #   Returns an empty string (e.g., <tt>"enter"</tt>, <tt>"up"</tt>, <tt>"f1"</tt>).
      #
      # This is equivalent to +to_s+.
      #
      #   RatatuiRuby::Event::Key.new(code: "a").char      # => "a"
      #   RatatuiRuby::Event::Key.new(code: "enter").char  # => ""
      def char
        to_s
      end

      # Supports dynamic key predicate methods via method_missing.
      #
      # Allows convenient checking for specific keys or key combinations:
      #
      #   event.ctrl_c?     # => true if Ctrl+C
      #   event.enter?      # => true if Enter
      #   event.shift_up?   # => true if Shift+Up
      #   event.q?          # => true if "q"
      #
      # The method name is converted to a symbol and compared against the event.
      # This works for any key code or modifier+key combination.
      def method_missing(name, *args, &block)
        if name.to_s.end_with?("?")
          key_sym = name.to_s[0...-1].to_sym
          return self == key_sym
        end
        super
      end

      # Declares that this class responds to dynamic predicate methods.
      def respond_to_missing?(name, *args)
        name.to_s.end_with?("?") || super
      end

      # Deconstructs the event for pattern matching.
      #
      #   case event
      #   in type: :key, code: "c", modifiers: ["ctrl"]
      #     puts "Ctrl+C pressed"
      #   end
      def deconstruct_keys(keys)
        { type: :key, code: @code, modifiers: @modifiers }
      end
    end
  end
end
