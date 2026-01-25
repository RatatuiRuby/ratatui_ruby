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
  end
end
