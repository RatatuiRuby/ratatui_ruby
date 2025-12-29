# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Base class for all RatatuiRuby events.
  #
  # Events are returned by RatatuiRuby.poll_event.
  # All events support Ruby 3.0+ pattern matching via #deconstruct_keys.
  #
  # See RatatuiRuby.poll_event
  class Event
    # Returns true if this is a Key event.
    def key?
      false
    end

    # Returns true if this is a Mouse event.
    def mouse?
      false
    end

    # Returns true if this is a Resize event.
    def resize?
      false
    end

    # Returns true if this is a Paste event.
    def paste?
      false
    end

    # Returns true if this is a FocusGained event.
    def focus_gained?
      false
    end

    # Returns true if this is a FocusLost event.
    def focus_lost?
      false
    end

    # Deconstructs the event for pattern matching.
    #
    # Keys argument is unused but required by the protocol.
    #
    #   case event
    #   in type: :key, code:
    #     puts "Key: #{code}"
    #   end
    def deconstruct_keys(keys)
      {}
    end

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
          "#{mods}_#{@code}".to_sym
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
      #   Button name (String).
      # [modifiers]
      #   List of modifiers (Array<String>).
      def initialize(kind:, x:, y:, button:, modifiers: [])
        @kind = kind
        @x = x
        @y = y
        @button = button
        @modifiers = modifiers.sort
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
        @content = content
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

    # Signals that the application is now active.
    #
    # The user interacts with many windows. Your application needs to know when it has their attention.
    #
    # This event confirms visibility. It fires when the terminal window moves to the foreground.
    #
    # Use it to resume paused activities. Restart animations. Refresh data. The user is watching.
    #
    # Only supported by some terminals (e.g. iTerm2, Kitty, newer xterm).
    #
    # === Example
    #
    #   if event.focus_gained?
    #     puts "Focus gained"
    #   end
    class FocusGained < Event
      # Returns true for FocusGained events.
      #
      #   event.focus_gained? # => true
      #   event.key?          # => false
      def focus_gained?
        true
      end

      # Deconstructs the event for pattern matching.
      #
      #   case event
      #   in type: :focus_gained
      #     puts "Application gained focus"
      #   end
      def deconstruct_keys(keys)
        { type: :focus_gained }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        other.is_a?(FocusGained)
      end
    end

    # Signals that the application is in the background.
    #
    # The user has switched context. Your application is no longer the primary focus.
    #
    # This event warns of inactivity. It fires when the terminal window loses focus.
    #
    # Respond by conserving resources. Pause animations. Stop heavy polling. dim the UI to
    # indicate a background state.
    #
    # Only supported by some terminals (e.g. iTerm2, Kitty, newer xterm).
    #
    # === Example
    #
    #   if event.focus_lost?
    #     puts "Focus lost"
    #   end
    class FocusLost < Event
      # Returns true for FocusLost events.
      #
      #   event.focus_lost? # => true
      #   event.key?        # => false
      def focus_lost?
        true
      end

      # Deconstructs the event for pattern matching.
      #
      #   case event
      #   in type: :focus_lost
      #     puts "Application lost focus"
      #   end
      def deconstruct_keys(keys)
        { type: :focus_lost }
      end

      ##
      # Compares this event with another for equality.
      def ==(other)
        other.is_a?(FocusLost)
      end
    end
  end
end
