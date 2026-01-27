# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestKey < Minitest::Test
    def test_key_initialization
      event = Event::Key.new(code: "c", modifiers: ["ctrl"])
      assert_equal "c", event.code
      assert_equal ["ctrl"], event.modifiers
      assert_predicate event, :key?
      refute_predicate event, :mouse?
    end

    def test_modifiers_sorting
      event = Event::Key.new(code: "a", modifiers: ["shift", "ctrl", "alt"])
      assert_equal ["alt", "ctrl", "shift"], event.modifiers
    end

    def test_predicates
      event = Event::Key.new(code: "c", modifiers: ["ctrl", "alt", "shift"])
      assert_predicate event, :ctrl?
      assert_predicate event, :alt?
      assert_predicate event, :shift?

      event = Event::Key.new(code: "a")
      refute_predicate event, :ctrl?
      refute_predicate event, :alt?
      refute_predicate event, :shift?
    end

    def test_text_predicate
      assert_predicate Event::Key.new(code: "a"), :text?
      assert_predicate Event::Key.new(code: "1"), :text?
      assert_predicate Event::Key.new(code: " "), :text?

      refute_predicate Event::Key.new(code: "enter"), :text?
      refute_predicate Event::Key.new(code: "tab"), :text?
      refute_predicate Event::Key.new(code: "f1"), :text?
    end

    def test_object_equality
      event = Event::Key.new(code: "c", modifiers: ["ctrl"])
      assert_equal event, Event::Key.new(code: "c", modifiers: ["ctrl"])
      refute_equal event, Event::Key.new(code: "d", modifiers: ["ctrl"])
      refute_equal event, Event::Key.new(code: "c", modifiers: [])
    end

    def test_symbol_equality
      event = Event::Key.new(code: "c", modifiers: ["ctrl"])
      assert_equal event, :ctrl_c
      refute_equal event, :c

      event_enter = Event::Key.new(code: "enter")
      assert_equal event_enter, :enter
    end

    def test_string_equality
      event = Event::Key.new(code: "c", modifiers: ["ctrl"])
      # Key with modifiers usually returns just the code for to_s if text
      assert_equal "c", event.to_s
      assert_equal event, "c"

      event_enter = Event::Key.new(code: "enter")
      assert_equal "", event_enter.to_s # Special keys return empty string
    end

    def test_to_sym
      assert_equal :a, Event::Key.new(code: "a").to_sym
      assert_equal :ctrl_c, Event::Key.new(code: "c", modifiers: ["ctrl"]).to_sym
      assert_equal :alt_enter, Event::Key.new(code: "enter", modifiers: ["alt"]).to_sym
      assert_equal :alt_ctrl_delete, Event::Key.new(code: "delete", modifiers: ["ctrl", "alt"]).to_sym
    end

    def test_deconstruct_keys
      event = Event::Key.new(code: "q", modifiers: ["ctrl"])
      pattern = event.deconstruct_keys(nil)

      assert_equal :key, pattern[:type]
      assert_equal "q", pattern[:code]
      assert_equal ["ctrl"], pattern[:modifiers]
      assert_equal :standard, pattern[:kind]
    end

    def test_duck_typed_pattern_matching
      event = Event::Key.new(code: "q", modifiers: ["ctrl"])
      matched = false
      case event
      in type: :key, code: "q", modifiers: ["ctrl"]
        matched = true
      end
      assert matched
    end

    def test_exact_pattern_matching
      event = Event::Key.new(code: "q", modifiers: ["ctrl"])
      matched = false
      case event
      in RatatuiRuby::Event::Key(code: "q", modifiers: ["ctrl"])
        matched = true
      end
      assert matched
    end

    def test_inspect
      event = Event::Key.new(code: "a", modifiers: ["ctrl"])
      assert_match(/#<RatatuiRuby::Event::Key code="a" modifiers=\["ctrl"\] kind=:standard>/, event.inspect)
    end

    def test_char_method
      # Printable character
      event_a = Event::Key.new(code: "a")
      assert_equal "a", event_a.char

      # Special key
      event_enter = Event::Key.new(code: "enter")
      assert_nil event_enter.char

      # Space
      event_space = Event::Key.new(code: " ")
      assert_equal " ", event_space.char
    end

    def test_dynamic_predicates
      # Single character
      event_q = Event::Key.new(code: "q")
      assert_predicate event_q, :q?
      refute_predicate event_q, :p?

      # Special keys
      event_enter = Event::Key.new(code: "enter")
      assert_predicate event_enter, :enter?
      refute_predicate event_enter, :tab?

      # Capital letters
      event_cap_g = Event::Key.new(code: "G", modifiers: ["shift"])
      event_alt_cap_b = Event::Key.new(code: "B", modifiers: ["alt", "shift"])
      assert_predicate event_cap_g, :G?
      assert_predicate event_alt_cap_b, :B?
      assert_predicate event_cap_g, :shift_g?
      assert_predicate event_cap_g, :shift_G?
      assert_predicate event_alt_cap_b, :alt_shift_b?
      assert_predicate event_alt_cap_b, :alt_shift_B?
      assert_predicate event_alt_cap_b, :alt_B?
      refute_predicate event_cap_g, :shift_b?
      refute_predicate event_alt_cap_b, :shift_g?

      # Numbers/Symbols
      event_1 = Event::Key.new(code: "1")
      event_at_sign = Event::Key.new(code: "@", modifiers: ["shift"])
      assert_predicate event_1, :"1?"
      refute_predicate event_1, :"2?"
      assert_predicate event_at_sign, :"@?"
      refute_predicate event_at_sign, :"1?"
      assert_predicate event_at_sign, :"shift_@?"
      refute_predicate event_at_sign, :shift_1? # i18n means this would be impractical

      # With modifiers
      event_ctrl_c = Event::Key.new(code: "c", modifiers: ["ctrl"])
      assert_predicate event_ctrl_c, :ctrl_c?
      refute_predicate event_ctrl_c, :c?
      refute_predicate event_ctrl_c, :ctrl_d?

      # Multiple modifiers
      event_alt_shift_up = Event::Key.new(code: "up", modifiers: ["alt", "shift"])
      assert_predicate event_alt_shift_up, :alt_shift_up?
      refute_predicate event_alt_shift_up, :alt_up?
      refute_predicate event_alt_shift_up, :shift_up?
    end

    # Arrow keys have DWIM aliases so you can be explicit about arrows vs mouse
    # Mouse events also respond to up?/down?, so arrow_up? disambiguates
    def test_arrow_key_dwim_aliases
      up = Event::Key.new(code: "up")
      down = Event::Key.new(code: "down")
      left = Event::Key.new(code: "left")
      right = Event::Key.new(code: "right")

      # arrow_* variants
      assert_predicate up, :arrow_up?
      assert_predicate down, :arrow_down?
      assert_predicate left, :arrow_left?
      assert_predicate right, :arrow_right?

      # *_arrow variants
      assert_predicate up, :up_arrow?
      assert_predicate down, :down_arrow?
      assert_predicate left, :left_arrow?
      assert_predicate right, :right_arrow?

      # Negative cases: arrows shouldn't match other arrows
      refute_predicate up, :arrow_down?
      refute_predicate down, :arrow_up?
      refute_predicate left, :arrow_right?
      refute_predicate right, :arrow_left?
    end

    # All key predicates work with key_ prefix or _key suffix
    # This disambiguates from mouse events (e.g., key_up? vs mouse up?)
    def test_key_prefix_and_suffix_predicates
      up = Event::Key.new(code: "up")
      enter = Event::Key.new(code: "enter")
      q = Event::Key.new(code: "q")
      cap_g = Event::Key.new(code: "G", modifiers: ["shift"])
      alt_cap_b = Event::Key.new(code: "B", modifiers: ["alt", "shift"])
      one = Event::Key.new(code: "1")
      at_sign = Event::Key.new(code: "@", modifiers: ["shift"])

      # key_ prefix
      assert_predicate up, :key_up?
      assert_predicate enter, :key_enter?
      assert_predicate q, :key_q?
      assert_predicate cap_g, :key_G?
      assert_predicate alt_cap_b, :key_B?
      assert_predicate alt_cap_b, :key_alt_shift_b?
      assert_predicate one, :key_1?
      assert_predicate at_sign, :"key_@?"

      # _key suffix
      assert_predicate up, :up_key?
      assert_predicate enter, :enter_key?
      assert_predicate q, :q_key?
      assert_predicate cap_g, :G_key?
      assert_predicate alt_cap_b, :B_key?
      assert_predicate alt_cap_b, :alt_shift_b_key?
      assert_predicate one, :"1_key?"
      assert_predicate at_sign, :"@_key?"

      # Negative cases
      refute_predicate up, :key_down?
      refute_predicate enter, :key_tab?
      refute_predicate q, :key_p?
    end

    # key_ prefix should work with underscore insensitivity
    def test_key_prefix_and_suffix_with_underscore_insensitivity
      page_up = Event::Key.new(code: "page_up")

      # Both forms should work
      assert_predicate page_up, :key_page_up?
      assert_predicate page_up, :key_pageup?
      assert_predicate page_up, :page_up_key?
      assert_predicate page_up, :pageup_key?
    end

    # =========================================================================
    # DWIM Predicates - Things People Might Try
    # =========================================================================

    # Space is a common key - people might call it by name
    def test_dwim_space_predicates
      space = Event::Key.new(code: " ")

      assert_predicate space, :space?
      assert_predicate space, :space_bar?
      assert_predicate space, :spacebar?
    end

    # Terminal hackers think in CR/LF terms
    def test_dwim_terminal_character_aliases
      enter = Event::Key.new(code: "enter")

      assert_predicate enter, :cr?
      assert_predicate enter, :carriage_return?
      assert_predicate enter, :carriagereturn?
      assert_predicate enter, :new_line?
      assert_predicate enter, :line_feed?
      assert_predicate enter, :linefeed?
      assert_predicate enter, :lf?
    end

    # Character category predicates - "is this a letter?"
    def test_dwim_character_category_predicates
      letter_a = Event::Key.new(code: "a")
      letter_z = Event::Key.new(code: "Z", modifiers: ["shift"])
      digit_5 = Event::Key.new(code: "5")
      space = Event::Key.new(code: " ")
      at_sign = Event::Key.new(code: "@", modifiers: ["shift"])
      enter = Event::Key.new(code: "enter")

      # letter?
      assert_predicate letter_a, :letter?
      assert_predicate letter_z, :letter?
      refute_predicate digit_5, :letter?
      refute_predicate space, :letter?
      refute_predicate at_sign, :letter?
      refute_predicate enter, :letter?

      # digit?
      assert_predicate digit_5, :digit?
      refute_predicate letter_a, :digit?
      refute_predicate space, :digit?
      refute_predicate enter, :digit?

      # alphanumeric?
      assert_predicate letter_a, :alpha_numeric?
      assert_predicate letter_z, :alpha_numeric?
      assert_predicate digit_5, :alpha_numeric?
      refute_predicate space, :alpha_numeric?
      refute_predicate at_sign, :alpha_numeric?
      refute_predicate enter, :alpha_numeric?
      assert_predicate letter_a, :alphanumeric?
      assert_predicate letter_z, :alphanumeric?
      assert_predicate digit_5, :alphanumeric?
      refute_predicate space, :alphanumeric?
      refute_predicate at_sign, :alphanumeric?
      refute_predicate enter, :alphanumeric?

      # punctuation?
      assert_predicate at_sign, :punctuation?
      refute_predicate letter_a, :punctuation?
      refute_predicate digit_5, :punctuation?
      refute_predicate space, :punctuation?
      refute_predicate enter, :punctuation?

      # whitespace?
      assert_predicate space, :white_space?
      refute_predicate letter_a, :white_space?
      assert_predicate enter, :white_space? # newlines are whitespace
      assert_predicate space, :whitespace?
      refute_predicate letter_a, :whitespace?
      assert_predicate enter, :whitespace? # newlines are whitespace
    end

    # Punctuation name predicates - named shortcuts for symbols
    def test_dwim_punctuation_name_predicates
      tilde = Event::Key.new(code: "~", modifiers: ["shift"])
      slash = Event::Key.new(code: "/")
      backslash = Event::Key.new(code: "\\")

      assert_predicate tilde, :tilde?
      assert_predicate slash, :slash?
      assert_predicate slash, :forward_slash?
      assert_predicate backslash, :backslash?
      assert_predicate backslash, :back_slash?

      comma = Event::Key.new(code: ",")
      period = Event::Key.new(code: ".")
      colon = Event::Key.new(code: ":", modifiers: ["shift"])
      semicolon = Event::Key.new(code: ";")

      assert_predicate comma, :comma?
      assert_predicate period, :period?
      assert_predicate period, :dot?
      assert_predicate colon, :colon?
      assert_predicate semicolon, :semicolon?
      assert_predicate semicolon, :semi_colon?

      question = Event::Key.new(code: "?", modifiers: ["shift"])
      exclamation = Event::Key.new(code: "!", modifiers: ["shift"])

      assert_predicate question, :question?
      assert_predicate question, :question_mark?
      assert_predicate question, :questionmark?
      assert_predicate exclamation, :exclamation?
      assert_predicate exclamation, :exclamation_mark?
      assert_predicate exclamation, :exclamation_point?
      assert_predicate exclamation, :exclamationmark?
      assert_predicate exclamation, :exclamationpoint?
      assert_predicate exclamation, :bang?

      at = Event::Key.new(code: "@", modifiers: ["shift"])
      hash = Event::Key.new(code: "#", modifiers: ["shift"])
      dollar = Event::Key.new(code: "$", modifiers: ["shift"])
      percent = Event::Key.new(code: "%", modifiers: ["shift"])
      caret = Event::Key.new(code: "^", modifiers: ["shift"])
      ampersand = Event::Key.new(code: "&", modifiers: ["shift"])
      asterisk = Event::Key.new(code: "*", modifiers: ["shift"])

      assert_predicate at, :at?
      assert_predicate at, :at_sign?
      assert_predicate hash, :hash?
      assert_predicate hash, :pound?
      assert_predicate hash, :number_sign?
      assert_predicate dollar, :dollar?
      assert_predicate dollar, :dollar_sign?
      assert_predicate percent, :percent?
      assert_predicate caret, :caret?
      assert_predicate caret, :circumflex?
      assert_predicate ampersand, :ampersand?
      assert_predicate asterisk, :asterisk?
      assert_predicate asterisk, :star?

      # Arithmetic and comparison
      underscore = Event::Key.new(code: "_", modifiers: ["shift"])
      hyphen = Event::Key.new(code: "-")
      plus = Event::Key.new(code: "+", modifiers: ["shift"])
      equals = Event::Key.new(code: "=")
      pipe = Event::Key.new(code: "|", modifiers: ["shift"])
      lt = Event::Key.new(code: "<", modifiers: ["shift"])
      gt = Event::Key.new(code: ">", modifiers: ["shift"])

      assert_predicate underscore, :underscore?
      assert_predicate hyphen, :hyphen?
      assert_predicate hyphen, :dash?
      assert_predicate hyphen, :minus?
      assert_predicate plus, :plus?
      assert_predicate equals, :equals?
      assert_predicate equals, :equal_sign?
      assert_predicate equals, :equalsign?
      # Note: equal? is Ruby's identity check, don't clobber it
      assert_predicate pipe, :pipe?
      assert_predicate pipe, :bar?
      assert_predicate lt, :less_than?
      assert_predicate lt, :lessthan?
      assert_predicate lt, :lt?
      assert_predicate gt, :greater_than?
      assert_predicate gt, :greaterthan?
      assert_predicate gt, :gt?

      # Brackets and parens
      lparen = Event::Key.new(code: "(", modifiers: ["shift"])
      rparen = Event::Key.new(code: ")", modifiers: ["shift"])
      lbracket = Event::Key.new(code: "[")
      rbracket = Event::Key.new(code: "]")
      lbrace = Event::Key.new(code: "{", modifiers: ["shift"])
      rbrace = Event::Key.new(code: "}", modifiers: ["shift"])

      assert_predicate lparen, :lparen?
      assert_predicate lparen, :left_paren?
      assert_predicate lparen, :open_paren?
      assert_predicate rparen, :rparen?
      assert_predicate rparen, :right_paren?
      assert_predicate rparen, :close_paren?
      assert_predicate lbracket, :lbracket?
      assert_predicate lbracket, :left_bracket?
      assert_predicate lbracket, :open_bracket?
      assert_predicate rbracket, :rbracket?
      assert_predicate rbracket, :right_bracket?
      assert_predicate rbracket, :close_bracket?
      assert_predicate lbrace, :lbrace?
      assert_predicate lbrace, :left_brace?
      assert_predicate lbrace, :open_brace?
      assert_predicate rbrace, :rbrace?
      assert_predicate rbrace, :right_brace?
      assert_predicate rbrace, :close_brace?

      # Quotes
      backtick = Event::Key.new(code: "`")
      single_quote = Event::Key.new(code: "'")
      double_quote = Event::Key.new(code: "\"", modifiers: ["shift"])

      assert_predicate backtick, :backtick?
      assert_predicate backtick, :back_tick?
      assert_predicate backtick, :grave?
      assert_predicate single_quote, :single_quote?
      assert_predicate single_quote, :singlequote?
      assert_predicate single_quote, :apostrophe?
      assert_predicate double_quote, :double_quote?
      assert_predicate double_quote, :doublequote?
      assert_predicate single_quote, :quote?
      assert_predicate double_quote, :quote?
      refute_predicate backtick, :quote?
    end

    # Modifier cross-platform aliases
    def test_dwim_modifier_platform_aliases
      ctrl_event = Event::Key.new(code: "c", modifiers: ["ctrl"])
      alt_event = Event::Key.new(code: "o", modifiers: ["alt"])
      super_event = Event::Key.new(code: "s", modifiers: ["super"])

      # option? is macOS name for alt
      assert_predicate alt_event, :option?
      refute_predicate ctrl_event, :option?

      # control? as full spelling of ctrl
      assert_predicate ctrl_event, :control?
      refute_predicate alt_event, :control?

      # command?/cmd? for macOS (maps to super)
      assert_predicate super_event, :command?
      assert_predicate super_event, :cmd?
      refute_predicate ctrl_event, :command?

      # win?/windows? for Windows users (maps to super)
      assert_predicate super_event, :win?
      assert_predicate super_event, :windows?
      refute_predicate ctrl_event, :windows?
    end

    # Quit-related common predicates
    def test_dwim_quit_predicates
      ctrl_c = Event::Key.new(code: "c", modifiers: ["ctrl"])
      ctrl_q = Event::Key.new(code: "q", modifiers: ["ctrl"])
      ctrl_d = Event::Key.new(code: "d", modifiers: ["ctrl"])
      esc = Event::Key.new(code: "esc")
      q = Event::Key.new(code: "q")

      # interrupt? - the classic Ctrl+C
      assert_predicate ctrl_c, :interrupt?
      refute_predicate ctrl_q, :interrupt?

      # eof? - Ctrl+D (end of file)
      assert_predicate ctrl_d, :eof?
      refute_predicate ctrl_c, :eof?

      # cancel? - Esc or Ctrl+C
      assert_predicate esc, :cancel?
      assert_predicate ctrl_c, :cancel?
      refute_predicate q, :cancel?
    end

    # Unix signal predicates
    def test_dwim_unix_signal_predicates
      ctrl_c = Event::Key.new(code: "c", modifiers: ["ctrl"])
      ctrl_z = Event::Key.new(code: "z", modifiers: ["ctrl"])
      ctrl_backslash = Event::Key.new(code: "\\", modifiers: ["ctrl"])
      ctrl_d = Event::Key.new(code: "d", modifiers: ["ctrl"])

      # interrupt?/sigint? - Ctrl+C (SIGINT)
      assert_predicate ctrl_c, :sigint?
      refute_predicate ctrl_z, :sigint?
      assert_predicate ctrl_c, :sig_int?
      refute_predicate ctrl_z, :sig_int?
      assert_predicate ctrl_c, :int?
      refute_predicate ctrl_z, :int?

      # suspend?/sigtstp? - Ctrl+Z (SIGTSTP)
      # Note: stop? is reserved for media_stop key
      assert_predicate ctrl_z, :suspend?
      assert_predicate ctrl_z, :sigtstp?
      assert_predicate ctrl_z, :sig_tstp?
      assert_predicate ctrl_z, :tstp?
      refute_predicate ctrl_c, :suspend?

      # quit?/sigquit? - Ctrl+\ (SIGQUIT)
      assert_predicate ctrl_backslash, :quit?
      assert_predicate ctrl_backslash, :sigquit?
      refute_predicate ctrl_c, :sigquit?
      assert_predicate ctrl_backslash, :sig_quit?
      refute_predicate ctrl_c, :sig_quit?

      # eof?/sigeof? - Ctrl+D
      assert_predicate ctrl_d, :eof?
      refute_predicate ctrl_z, :eof?
    end

    # Movement predicates (conceptual, not just arrow names)
    def test_dwim_movement_predicates
      up = Event::Key.new(code: "up")
      down = Event::Key.new(code: "down")
      left = Event::Key.new(code: "left")
      right = Event::Key.new(code: "right")
      home = Event::Key.new(code: "home")
      end_key = Event::Key.new(code: "end")
      page_up = Event::Key.new(code: "page_up")
      page_down = Event::Key.new(code: "page_down")
      h = Event::Key.new(code: "h")
      j = Event::Key.new(code: "j")
      k = Event::Key.new(code: "k")
      l = Event::Key.new(code: "l")

      # navigation? - any navigation key
      assert_predicate up, :navigation?
      assert_predicate down, :navigation?
      assert_predicate left, :navigation?
      assert_predicate right, :navigation?
      assert_predicate home, :navigation?
      assert_predicate end_key, :navigation?
      assert_predicate page_up, :navigation?
      assert_predicate page_down, :navigation?
      refute_predicate h, :navigation? # hjkl are characters, not navigation keys
      refute_predicate j, :navigation? # j is Vim down, but not a navigation key
      refute_predicate k, :navigation? # k is Vim up, but not a navigation key
      refute_predicate l, :navigation? # l is Vim right, but not a navigation key

      # arrow? - any arrow key
      assert_predicate up, :arrow?
      assert_predicate down, :arrow?
      assert_predicate left, :arrow?
      assert_predicate right, :arrow?
      refute_predicate home, :arrow?
      refute_predicate page_up, :arrow?
    end

    # Vim-style predicates (common in TUI apps)
    def test_dwim_vim_movement_predicates
      h = Event::Key.new(code: "h")
      j = Event::Key.new(code: "j")
      k = Event::Key.new(code: "k")
      l = Event::Key.new(code: "l")
      w = Event::Key.new(code: "w")
      b = Event::Key.new(code: "b")
      g = Event::Key.new(code: "g")
      shift_g = Event::Key.new(code: "G", modifiers: ["shift"])

      # vim? - any of the hjkl/wb/gG keys
      assert_predicate h, :vim?
      assert_predicate j, :vim?
      assert_predicate k, :vim?
      assert_predicate l, :vim?
      assert_predicate w, :vim?
      assert_predicate b, :vim?
      assert_predicate g, :vim?
      assert_predicate shift_g, :vim?

      # vim_left?, vim_down?, etc.
      assert_predicate h, :vim_left?
      assert_predicate j, :vim_down?
      assert_predicate k, :vim_up?
      assert_predicate l, :vim_right?
      refute_predicate h, :vim_up?
      refute_predicate j, :vim_left?

      # Negative cases
      refute_predicate k, :vim_down?
      refute_predicate l, :vim_up?

      # word movement
      assert_predicate w, :vim_word_forward?
      assert_predicate b, :vim_word_backward?

      # g/G for top/bottom of file
      assert_predicate g, :vim_top?
      assert_predicate shift_g, :vim_bottom?
      refute_predicate g, :vim_bottom?
      refute_predicate shift_g, :vim_top?
    end
  end
end

def test_dwim_punctuation_name_predicates
  tilde = Event::Key.new(code: "~", modifiers: ["shift"])
  assert_predicate tilde, :tilde?
end
