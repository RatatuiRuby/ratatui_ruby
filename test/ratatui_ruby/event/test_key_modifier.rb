# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for modifier KeyCode variants through the Rust FFI layer.
  #
  # Tests all ModifierKeyCode variants: LeftShift, LeftControl, LeftAlt, LeftSuper,
  # LeftHyper, LeftMeta, RightShift, RightControl, RightAlt, RightSuper, RightHyper,
  # RightMeta, IsoLevel3Shift, IsoLevel5Shift.
  #
  # These are individual modifier key events, distinct from modifier *flags* on
  # other key events. Requires enhanced keyboard protocol for real terminal detection.
  class TestKeyModifier < Minitest::Test
    include RatatuiRuby::TestHelper

    def test_left_shift
      with_test_terminal do
        inject_keys("left_shift")
        event = RatatuiRuby.poll_event

        assert_equal "left_shift", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.left_shift?
        refute event.ctrl?
        # Modifier keys themselves do not inherently set modifier flags
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left_control
      with_test_terminal do
        inject_keys("left_control")
        event = RatatuiRuby.poll_event

        assert_equal "left_control", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.left_control?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left_alt
      with_test_terminal do
        inject_keys("left_alt")
        event = RatatuiRuby.poll_event

        assert_equal "left_alt", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.left_alt?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left_super
      with_test_terminal do
        inject_keys("left_super")
        event = RatatuiRuby.poll_event

        assert_equal "left_super", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.left_super?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left_hyper
      with_test_terminal do
        inject_keys("left_hyper")
        event = RatatuiRuby.poll_event

        assert_equal "left_hyper", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.left_hyper?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left_meta
      with_test_terminal do
        inject_keys("left_meta")
        event = RatatuiRuby.poll_event

        assert_equal "left_meta", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.left_meta?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right_shift
      with_test_terminal do
        inject_keys("right_shift")
        event = RatatuiRuby.poll_event

        assert_equal "right_shift", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.right_shift?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right_control
      with_test_terminal do
        inject_keys("right_control")
        event = RatatuiRuby.poll_event

        assert_equal "right_control", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.right_control?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right_alt
      with_test_terminal do
        inject_keys("right_alt")
        event = RatatuiRuby.poll_event

        assert_equal "right_alt", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.right_alt?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right_super
      with_test_terminal do
        inject_keys("right_super")
        event = RatatuiRuby.poll_event

        assert_equal "right_super", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.right_super?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right_hyper
      with_test_terminal do
        inject_keys("right_hyper")
        event = RatatuiRuby.poll_event

        assert_equal "right_hyper", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.right_hyper?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_right_meta
      with_test_terminal do
        inject_keys("right_meta")
        event = RatatuiRuby.poll_event

        assert_equal "right_meta", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.right_meta?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_iso_level3_shift
      with_test_terminal do
        inject_keys("iso_level3_shift")
        event = RatatuiRuby.poll_event

        assert_equal "iso_level3_shift", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.iso_level3_shift?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_iso_level5_shift
      with_test_terminal do
        inject_keys("iso_level5_shift")
        event = RatatuiRuby.poll_event

        assert_equal "iso_level5_shift", event.code
        refute event.text?
        assert_equal "", event.char

        assert event.iso_level5_shift?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_left_modifiers_are_distinct_from_right
      with_test_terminal do
        inject_keys("left_shift")
        left = RatatuiRuby.poll_event
        inject_keys("right_shift")
        right = RatatuiRuby.poll_event

        refute_equal left.code, right.code
        assert_equal "left_shift", left.code
        assert_equal "right_shift", right.code
      end
    end

    def test_iso_modifiers_distinct_from_standard
      with_test_terminal do
        inject_keys("iso_level3_shift")
        iso3 = RatatuiRuby.poll_event
        inject_keys("left_shift")
        left = RatatuiRuby.poll_event

        refute_equal iso3.code, left.code
      end
    end
  end
end
