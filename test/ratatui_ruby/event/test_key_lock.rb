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

        # Precise
        assert_equal "caps_lock", event.code
        assert event.caps_lock?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.standard?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_num_lock
      with_test_terminal do
        inject_keys("num_lock")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "num_lock", event.code
        assert event.num_lock?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.function?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_scroll_lock
      with_test_terminal do
        inject_keys("scroll_lock")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "scroll_lock", event.code
        assert event.scroll_lock?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.media?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end
  end
end
