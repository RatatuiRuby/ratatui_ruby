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
    #
    # === Terminal Compatibility
    #
    # Some key combinations never reach your application. Terminal emulators intercept them for
    # built-in features like tab switching. Common culprits:
    #
    # * Ctrl+PageUp/PageDown (tab switching in Terminal.app, iTerm2)
    # * Ctrl+Tab (tab switching)
    # * Cmd+key combinations (macOS system shortcuts)
    #
    # If modifiers appear missing, test with a different terminal. Kitty, WezTerm, and Alacritty
    # pass more keys through. See <tt>doc/terminal_limitations.md</tt> for details.
    #
    # === Enhanced Keys (Kitty Protocol)
    #
    # Terminals supporting the Kitty keyboard protocol report additional keys:
    #
    # * Media keys: <tt>:play</tt>, <tt>:play_pause</tt>, <tt>:track_next</tt>, <tt>:mute_volume</tt>
    # * Individual modifiers: <tt>:left_shift</tt>, <tt>:right_control</tt>, <tt>:left_super</tt>
    #
    # These keys will not work in Terminal.app, iTerm2, or GNOME Terminal.
    class Key < Event
      # The key code (e.g., <tt>"a"</tt>, <tt>"enter"</tt>, <tt>"up"</tt>).
      #
      #   puts event.code # => "enter"
      attr_reader :code

      # List of active modifiers (<tt>"ctrl"</tt>, <tt>"alt"</tt>, <tt>"shift"</tt>).
      #
      #   puts event.modifiers # => ["ctrl", "shift"]
      attr_reader :modifiers

      # The category of the key.
      #
      # One of: <tt>:standard</tt>, <tt>:function</tt>, <tt>:media</tt>, <tt>:modifier</tt>, <tt>:system</tt>.
      #
      # This allows grouping keys by their logical type without parsing the code string.
      #
      #   event.kind # => :media
      attr_reader :kind

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
      # [kind]
      #   The key category (Symbol). One of: <tt>:standard</tt>, <tt>:function</tt>,
      #   <tt>:media</tt>, <tt>:modifier</tt>, <tt>:system</tt>. Defaults to <tt>:standard</tt>.
      def initialize(code:, modifiers: [], kind: :standard)
        @code = code.freeze
        @modifiers = modifiers.map(&:freeze).sort.freeze
        @kind = kind
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
      #   <tt>:enter</tt>, <tt>:backspace</tt>, <tt>:tab</tt>, <tt>:back_tab</tt>, <tt>:esc</tt>, <tt>:null</tt>
      # [Navigation]
      #   <tt>:up</tt>, <tt>:down</tt>, <tt>:left</tt>, <tt>:right</tt>, <tt>:home</tt>, <tt>:end</tt>,
      #   <tt>:page_up</tt>, <tt>:page_down</tt>, <tt>:insert</tt>, <tt>:delete</tt>
      # [Function Keys]
      #   <tt>:f1</tt> through <tt>:f12</tt> (and beyond, e.g. <tt>:f24</tt>)
      # [Lock Keys]
      #   <tt>:caps_lock</tt>, <tt>:scroll_lock</tt>, <tt>:num_lock</tt>
      # [System Keys]
      #   <tt>:print_screen</tt>, <tt>:pause</tt>, <tt>:menu</tt>, <tt>:keypad_begin</tt>
      # [Media Keys]
      #   <tt>:play</tt>, <tt>:media_pause</tt>, <tt>:play_pause</tt>, <tt>:reverse</tt>, <tt>:stop</tt>,
      #   <tt>:fast_forward</tt>, <tt>:rewind</tt>, <tt>:track_next</tt>, <tt>:track_previous</tt>,
      #   <tt>:record</tt>, <tt>:lower_volume</tt>, <tt>:raise_volume</tt>, <tt>:mute_volume</tt>
      # [Modifier Keys]
      #   <tt>:left_shift</tt>, <tt>:left_control</tt>, <tt>:left_alt</tt>, <tt>:left_super</tt>,
      #   <tt>:left_hyper</tt>, <tt>:left_meta</tt>, <tt>:right_shift</tt>, <tt>:right_control</tt>,
      #   <tt>:right_alt</tt>, <tt>:right_super</tt>, <tt>:right_hyper</tt>, <tt>:right_meta</tt>,
      #   <tt>:iso_level3_shift</tt>, <tt>:iso_level5_shift</tt>
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
        "#<#{self.class} code=#{@code.inspect} modifiers=#{@modifiers.inspect} kind=#{@kind.inspect}>"
      end

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

      # Returns true if this is a media key.
      #
      # Media keys include: play, pause, stop, track controls, volume controls.
      # These are only available in terminals supporting the Kitty keyboard protocol.
      #
      #   event.media? # => true for media_play, media_pause, etc.
      def media?
        @kind == :media
      end

      # Returns true if this is a system key.
      #
      # System keys include: Esc, CapsLock, ScrollLock, NumLock, PrintScreen, Pause, Menu, KeypadBegin.
      #
      #   event.system? # => true for pause, esc, caps_lock, etc.
      def system?
        @kind == :system
      end

      # Returns true if this is a function key (F1-F24).
      #
      #   event.function? # => true for f1, f2, ..., f24
      def function?
        @kind == :function
      end

      # Returns true if this is a modifier key press.
      #
      # Modifier keys include: left_shift, right_control, left_alt, etc.
      # These are only available in terminals supporting the Kitty keyboard protocol.
      #
      #   event.modifier? # => true for left_shift, right_control, etc.
      def modifier?
        @kind == :modifier
      end

      # Returns true if this is a standard key.
      #
      # Standard keys include: characters, Enter, Tab, arrow keys, navigation keys.
      #
      #   event.standard? # => true for "a", "enter", "up", etc.
      def standard?
        @kind == :standard
      end

      # Alias for {#standard?}.
      #
      # Provided for semantic clarity when checking if a key has no special category.
      #
      #   event.unmodified? # => true for standard keys like "a", "enter", "up"
      alias unmodified? standard?

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
      #
      # === Smart Predicates (DWIM)
      #
      # For convenience, generic predicates match both system and media variants:
      #
      #   event.pause?      # => true for BOTH system "pause" AND "media_pause"
      #   event.play?       # => true for "media_play"
      #   event.stop?       # => true for "media_stop"
      #
      # This "Do What I Mean" behavior reduces boilerplate when you just want to
      # respond to a conceptual action (e.g., "pause the playback") regardless of
      # whether the user pressed a keyboard key or a media button.
      #
      # For strict matching, use the full predicate or compare the code directly:
      #
      #   event.media_pause?  # => true ONLY for media pause
      #   event.code == "pause"  # => true ONLY for system pause
      def method_missing(name, *args, &block)
        if name.to_s.end_with?("?")
          key_name = name.to_s[0...-1]
          key_sym = key_name.to_sym

          # Predicate alias mappings for common keyboard legends and shortcuts
          predicate_aliases = {
            # Common abbreviations
            return: "enter",
            back: "backspace",
            escape: "esc",
            del: "delete",
            ins: "insert",
            # Keyboard legends (what's printed on keys)
            pgup: "page_up",
            pageup: "page_up",
            pgdn: "page_down",
            pagedown: "page_down",
            scrlk: "scroll_lock",
            scroll: "scroll_lock",
            prtsc: "print_screen",
            print: "print_screen",
            # Platform modifier aliases
            win: "super",
            command: "super",
            cmd: "super",
            tux: "super"
          }.freeze

          # Fast path: Exact match (e.g., media_pause? for media_pause)
          return true if self == key_sym

          # DWIM: reverse_tab? matches both BackTab key and Shift+Tab combo
          if key_name == "reverse_tab"
            return true if @code == "back_tab"
            return true if @code == "tab" && @modifiers.include?("shift")
          end

          # DWIM: For media keys, allow unprefixed predicate
          # e.g., pause? returns true for media_pause
          if @kind == :media && @code.start_with?("media_")
            base_code = @code.delete_prefix("media_")
            return true if key_name == base_code
          end

          # DWIM: Bidirectional media overlaps
          # e.g., play? and pause? both match media_play_pause
          if @code == "media_play_pause"
            return true if key_name == "play" || key_name == "pause"
          end
          # e.g., play_pause? matches media_play or media_pause
          if key_name == "play_pause"
            return true if @code == "media_play" || @code == "media_pause"
          end

          # DWIM: Check explicit aliases
          target_code = predicate_aliases[key_sym]
          return true if target_code && @code == target_code && @modifiers.empty?

          # DWIM: Universal underscore-insensitivity
          # Normalize both predicate and code by stripping underscores
          normalized_predicate = key_name.delete("_")
          normalized_code = @code.delete("_")
          return true if normalized_predicate == normalized_code && @modifiers.empty?

          false
        else
          super
        end
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
      #   in type: :key, kind: :media
      #     puts "Media key pressed"
      #   end
      def deconstruct_keys(keys)
        { type: :key, code: @code, modifiers: @modifiers, kind: @kind }
      end
    end
  end
end
