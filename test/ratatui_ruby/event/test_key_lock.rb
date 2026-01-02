# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for lock KeyCode variants through the Rust FFI layer.
  #
  # Tests: CapsLock, ScrollLock, NumLock
  class TestKeyLock < Minitest::Test
    include RatatuiRuby::TestHelper

    def test_caps_lock
      with_test_terminal do
        inject_keys("caps_lock")
        event = RatatuiRuby.poll_event

        assert_equal "caps_lock", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.caps_lock?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_num_lock
      with_test_terminal do
        inject_keys("num_lock")
        event = RatatuiRuby.poll_event

        assert_equal "num_lock", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.num_lock?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_scroll_lock
      with_test_terminal do
        inject_keys("scroll_lock")
        event = RatatuiRuby.poll_event

        assert_equal "scroll_lock", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.scroll_lock?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end
  end
end
