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

        # Precise
        assert_equal "left_shift", event.code
        assert event.left_shift?

        # DWIM
        assert event.shift?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.standard?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        refute event.alt?
        # shift? now matches via DWIM (removed refutation)
        refute event.super?
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_left_control
      with_test_terminal do
        inject_keys("left_control")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left_control", event.code
        assert event.left_control?

        # DWIM
        assert event.ctrl?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.function?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        # ctrl? now matches via DWIM (removed refutation)
        refute event.alt?
        refute event.shift?
        refute event.super?
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_left_alt
      with_test_terminal do
        inject_keys("left_alt")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left_alt", event.code
        assert event.left_alt?

        # DWIM
        assert event.alt?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.media?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        # alt? now matches via DWIM (removed refutation)
        refute event.shift?
        refute event.super?
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_left_super
      with_test_terminal do
        inject_keys("left_super")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left_super", event.code
        assert event.left_super?

        # DWIM
        assert event.super?
        assert event.win?
        assert event.command?
        assert event.cmd?
        assert event.tux?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.system?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
        # super? now matches via DWIM (removed refutation)
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_left_hyper
      with_test_terminal do
        inject_keys("left_hyper")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left_hyper", event.code
        assert event.left_hyper?

        # DWIM
        assert event.hyper?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.standard?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
        # hyper? now matches via DWIM (removed refutation)
        refute event.meta?
      end
    end

    def test_left_meta
      with_test_terminal do
        inject_keys("left_meta")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left_meta", event.code
        assert event.left_meta?

        # DWIM
        assert event.meta?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.function?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
        refute event.hyper?
        # meta? now matches via DWIM (removed refutation)
      end
    end

    def test_right_shift
      with_test_terminal do
        inject_keys("right_shift")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right_shift", event.code
        assert event.right_shift?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.media?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        refute event.alt?
        # shift? now matches via DWIM (removed refutation)
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_right_control
      with_test_terminal do
        inject_keys("right_control")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right_control", event.code
        assert event.right_control?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.system?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        # ctrl? now matches via DWIM (removed refutation)
        refute event.alt?
        refute event.shift?
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_right_alt
      with_test_terminal do
        inject_keys("right_alt")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right_alt", event.code
        assert event.right_alt?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.standard?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        # alt? now matches via DWIM (removed refutation)
        refute event.shift?
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_right_super
      with_test_terminal do
        inject_keys("right_super")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right_super", event.code
        assert event.right_super?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.function?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers -- keys themselves do not inherently set modifier flags
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
        refute event.hyper?
        refute event.meta?
      end
    end

    def test_right_hyper
      with_test_terminal do
        inject_keys("right_hyper")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right_hyper", event.code
        assert event.right_hyper?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
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

    def test_right_meta
      with_test_terminal do
        inject_keys("right_meta")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right_meta", event.code
        assert event.right_meta?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.system?

        # Text
        refute event.text?
        assert_nil event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_iso_level3_shift
      with_test_terminal do
        inject_keys("iso_level3_shift")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "iso_level3_shift", event.code
        assert event.iso_level3_shift?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
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

    def test_iso_level5_shift
      with_test_terminal do
        inject_keys("iso_level5_shift")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "iso_level5_shift", event.code
        assert event.iso_level5_shift?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
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
