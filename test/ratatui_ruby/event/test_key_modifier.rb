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

    LEFT_MODIFIERS = %w[
      left_shift
      left_control
      left_alt
      left_super
      left_hyper
      left_meta
    ].freeze

    RIGHT_MODIFIERS = %w[
      right_shift
      right_control
      right_alt
      right_super
      right_hyper
      right_meta
    ].freeze

    ISO_MODIFIERS = %w[
      iso_level3_shift
      iso_level5_shift
    ].freeze

    ALL_MODIFIER_KEYS = (LEFT_MODIFIERS + RIGHT_MODIFIERS + ISO_MODIFIERS).freeze

    def test_all_modifier_keys_round_trip
      with_test_terminal do
        ALL_MODIFIER_KEYS.each do |key|
          inject_keys(key)
          event = RatatuiRuby.poll_event
          assert_equal key, event.code,
            "Modifier key '#{key}' should round-trip through FFI"
        end
      end
    end

    def test_left_modifiers_are_distinct_from_right
      with_test_terminal do
        inject_keys("left_shift")
        left = RatatuiRuby.poll_event
        inject_keys("right_shift")
        right = RatatuiRuby.poll_event

        refute_equal left.code, right.code,
          "Left and right modifiers should be distinct"
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

        refute_equal iso3.code, left.code,
          "ISO modifiers should be distinct from standard modifiers"
      end
    end
  end
end
