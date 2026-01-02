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

        assert_equal "backspace", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.backspace?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_enter
      with_test_terminal do
        inject_keys("enter")
        event = RatatuiRuby.poll_event

        assert_equal "enter", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.enter?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left
      with_test_terminal do
        inject_keys("left")
        event = RatatuiRuby.poll_event

        assert_equal "left", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.left?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right
      with_test_terminal do
        inject_keys("right")
        event = RatatuiRuby.poll_event

        assert_equal "right", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.right?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_up
      with_test_terminal do
        inject_keys("up")
        event = RatatuiRuby.poll_event

        assert_equal "up", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.up?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_down
      with_test_terminal do
        inject_keys("down")
        event = RatatuiRuby.poll_event

        assert_equal "down", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.down?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_home
      with_test_terminal do
        inject_keys("home")
        event = RatatuiRuby.poll_event

        assert_equal "home", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.home?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_end
      with_test_terminal do
        inject_keys("end")
        event = RatatuiRuby.poll_event

        assert_equal "end", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.end?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_page_up
      with_test_terminal do
        inject_keys("page_up")
        event = RatatuiRuby.poll_event

        assert_equal "page_up", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.page_up?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_page_down
      with_test_terminal do
        inject_keys("page_down")
        event = RatatuiRuby.poll_event

        assert_equal "page_down", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.page_down?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_tab
      with_test_terminal do
        inject_keys("tab")
        event = RatatuiRuby.poll_event

        assert_equal "tab", event.code
        # Tab is not considered printable text
        refute event.text?
        assert_equal "", event.char

        assert event.tab?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_back_tab
      with_test_terminal do
        inject_keys("back_tab")
        event = RatatuiRuby.poll_event

        assert_equal "back_tab", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.back_tab?
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

        assert_equal "delete", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.delete?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_insert
      with_test_terminal do
        inject_keys("insert")
        event = RatatuiRuby.poll_event

        assert_equal "insert", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.insert?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_null
      with_test_terminal do
        inject_keys("null")
        event = RatatuiRuby.poll_event

        assert_equal "null", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.null?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_esc
      with_test_terminal do
        inject_keys("esc")
        event = RatatuiRuby.poll_event

        assert_equal "esc", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.esc?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_ctrl_home
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "home", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event
        assert_equal "home", event.code
        assert event.ctrl?
        assert event.ctrl_home?
      end
    end

    def test_ctrl_end
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "end", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event
        assert_equal "end", event.code
        assert event.ctrl?
        assert event.ctrl_end?
      end
    end

    def test_ctrl_page_up
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "page_up", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event
        assert_equal "page_up", event.code
        assert event.ctrl?
        assert event.ctrl_page_up?
      end
    end

    def test_ctrl_page_down
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "page_down", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event
        assert_equal "page_down", event.code
        assert event.ctrl?
        assert event.ctrl_page_down?
      end
    end

    def test_ctrl_insert
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "insert", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event
        assert_equal "insert", event.code
        assert event.ctrl?
        assert event.ctrl_insert?
      end
    end

    def test_ctrl_delete
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "delete", modifiers: ["ctrl"]))
        event = RatatuiRuby.poll_event
        assert_equal "delete", event.code
        assert event.ctrl?
        assert event.ctrl_delete?
      end
    end

    def test_shift_up
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "up", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event
        assert_equal "up", event.code
        assert event.shift?
        assert event.shift_up?
      end
    end

    def test_shift_down
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "down", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event
        assert_equal "down", event.code
        assert event.shift?
        assert event.shift_down?
      end
    end

    def test_shift_left
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "left", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event
        assert_equal "left", event.code
        assert event.shift?
        assert event.shift_left?
      end
    end

    def test_shift_right
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "right", modifiers: ["shift"]))
        event = RatatuiRuby.poll_event
        assert_equal "right", event.code
        assert event.shift?
        assert event.shift_right?
      end
    end

    def test_multiple_modifiers_preserved
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "delete", modifiers: %w[ctrl alt shift]))
        event = RatatuiRuby.poll_event
        assert_equal "delete", event.code
        assert_includes event.modifiers, "ctrl"
        assert_includes event.modifiers, "alt"
        assert_includes event.modifiers, "shift"
      end
    end
  end
end
