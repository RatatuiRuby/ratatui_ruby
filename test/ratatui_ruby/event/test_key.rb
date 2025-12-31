# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
      assert_match(/#<RatatuiRuby::Event::Key code="a" modifiers=\["ctrl"\]>/, event.inspect)
    end

    def test_char_method
      # Printable character
      event_a = Event::Key.new(code: "a")
      assert_equal "a", event_a.char

      # Special key
      event_enter = Event::Key.new(code: "enter")
      assert_equal "", event_enter.char

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
   end
 end
