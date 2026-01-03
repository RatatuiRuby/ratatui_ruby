# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for simple KeyCode variants through the Rust FFI layer.
  #
  # Tests: Backspace, Enter, Left, Right, Up, Down, Home, End, PageUp, PageDown,
  # Tab, BackTab, Delete, Insert, Null, Esc
  class TestKeySimple < Minitest::Test
    include RatatuiRuby::TestHelper

    def test_backspace
      with_test_terminal do
        inject_keys("backspace")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "backspace", event.code
        assert event.backspace?

        # DWIM
        assert event.back?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_enter
      with_test_terminal do
        inject_keys("enter")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "enter", event.code
        assert event.enter?

        # DWIM
        assert event.return?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left
      with_test_terminal do
        inject_keys("left")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left", event.code
        assert event.left?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right
      with_test_terminal do
        inject_keys("right")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right", event.code
        assert event.right?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.system?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_up
      with_test_terminal do
        inject_keys("up")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "up", event.code
        assert event.up?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_down
      with_test_terminal do
        inject_keys("down")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "down", event.code
        assert event.down?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_home
      with_test_terminal do
        inject_keys("home")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "home", event.code
        assert event.home?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_end
      with_test_terminal do
        inject_keys("end")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "end", event.code
        assert event.end?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.system?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_page_up
      with_test_terminal do
        inject_keys("page_up")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "page_up", event.code
        assert event.page_up?

        # DWIM
        assert event.pageup? # Underscore-insensitive
        assert event.pgup?   # Keyboard legend

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_page_down
      with_test_terminal do
        inject_keys("page_down")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "page_down", event.code
        assert event.page_down?

        # DWIM
        assert event.pagedown? # Underscore-insensitive
        assert event.pgdn?     # Keyboard legend

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_tab
      with_test_terminal do
        inject_keys("tab")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "tab", event.code
        assert event.tab?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Text
        # Tab is not considered printable text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_back_tab
      with_test_terminal do
        inject_keys("back_tab")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "back_tab", event.code
        assert event.back_tab?

        # DWIM
        assert event.backtab?     # Underscore-insensitive
        assert event.reverse_tab? # Conceptual alias
        refute event.back?        # Should not match (different key)

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.system?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        # BackTab often implies shift in terminals, but we just verify the injected code here
        refute event.shift?
      end
    end

    def test_delete
      with_test_terminal do
        inject_keys("delete")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "delete", event.code
        assert event.delete?

        # DWIM
        assert event.del?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_insert
      with_test_terminal do
        inject_keys("insert")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "insert", event.code
        assert event.insert?

        # DWIM
        assert event.ins?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_null
      with_test_terminal do
        inject_keys("null")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "null", event.code
        assert event.null?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_esc
      with_test_terminal do
        inject_keys("esc")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "esc", event.code
        assert event.esc?

        # DWIM
        assert event.escape?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.standard?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_ctrl_home
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "home", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "home", event.code
        assert event.ctrl_home?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Modifiers
        assert event.ctrl?
      end
    end

    def test_ctrl_end
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "end", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "end", event.code
        assert event.ctrl_end?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Modifiers
        assert event.ctrl?
      end
    end

    def test_ctrl_page_up
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "page_up", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "page_up", event.code
        assert event.ctrl_page_up?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Modifiers
        assert event.ctrl?
      end
    end

    def test_ctrl_page_down
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "page_down", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "page_down", event.code
        assert event.ctrl_page_down?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.system?

        # Modifiers
        assert event.ctrl?
      end
    end

    def test_ctrl_insert
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "insert", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "insert", event.code
        assert event.ctrl_insert?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Modifiers
        assert event.ctrl?
      end
    end

    def test_ctrl_delete
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "delete", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "delete", event.code
        assert event.ctrl_delete?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Modifiers
        assert event.ctrl?
      end
    end

    def test_shift_up
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "up", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "up", event.code
        assert event.shift_up?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Modifiers
        assert event.shift?
      end
    end

    def test_shift_down
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "down", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "down", event.code
        assert event.shift_down?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.system?

        # Modifiers
        assert event.shift?
      end
    end

    def test_shift_left
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "left", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left", event.code
        assert event.shift_left?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Modifiers
        assert event.shift?
      end
    end

    def test_shift_right
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "right", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right", event.code
        assert event.shift_right?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.function?

        # Modifiers
        assert event.shift?
      end
    end

    def test_multiple_modifiers_preserved
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "delete", modifiers: %w[ctrl alt shift]))
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "delete", event.code

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?

        # Modifiers
        assert_includes event.modifiers, "ctrl"
        assert_includes event.modifiers, "alt"
        assert_includes event.modifiers, "shift"
      end
    end
  end
end
