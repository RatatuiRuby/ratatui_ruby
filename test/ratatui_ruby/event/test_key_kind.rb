# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Tests for the Key `kind` attribute and category predicates.
  #
  # Verifies that all key codes are properly categorized as:
  # :standard, :function, :media, :modifier, or :system
  class TestKeyKind < Minitest::Test
    include RatatuiRuby::TestHelper

    # --- Standard keys ---

    def test_character_keys_are_standard
      with_test_terminal do
        inject_keys("a")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "a", event.code
        assert event.a?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.media?

        # Text
        assert event.text?
        assert_equal "a", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_enter_is_standard
      with_test_terminal do
        inject_keys("enter")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "enter", event.code
        assert event.enter?

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

    def test_arrow_keys_are_standard
      with_test_terminal do
        inject_keys("up")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "up", event.code
        assert event.up?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.modifier?
      end
    end

    def test_navigation_keys_are_standard
      with_test_terminal do
        inject_keys("page_up")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "page_up", event.code
        assert event.page_up?

        # Kind
        assert_equal :standard, event.kind
        assert event.standard?
        refute event.system?
      end
    end

    # --- Function keys ---

    def test_function_keys_are_function
      with_test_terminal do
        inject_keys("f1")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "f1", event.code
        assert event.f1?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
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

    def test_f12_is_function
      with_test_terminal do
        inject_keys("f12")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "f12", event.code
        assert event.f12?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.standard?
      end
    end

    # --- Media keys ---

    def test_media_play_is_media
      with_test_terminal do
        inject_keys("media_play")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "media_play", event.code
        assert event.media_play?

        # Kind
        assert_equal :media, event.kind
        assert event.media?
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

    def test_media_pause_is_media
      with_test_terminal do
        inject_keys("media_pause")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "media_pause", event.code
        assert event.media_pause?

        # Kind
        assert_equal :media, event.kind
        assert event.media?
        refute event.modifier?
      end
    end

    # --- Modifier keys ---

    def test_left_shift_is_modifier
      with_test_terminal do
        inject_keys("left_shift")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "left_shift", event.code
        assert event.left_shift?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.system?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        # shift? now matches via DWIM (removed refutation)
      end
    end

    def test_right_control_is_modifier
      with_test_terminal do
        inject_keys("right_control")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "right_control", event.code
        assert event.right_control?

        # Kind
        assert_equal :modifier, event.kind
        assert event.modifier?
        refute event.standard?
      end
    end

    # --- System keys ---

    def test_esc_is_system
      with_test_terminal do
        inject_keys("esc")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "esc", event.code
        assert event.esc?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
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

    def test_caps_lock_is_system
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
      end
    end

    def test_pause_is_system
      with_test_terminal do
        inject_keys("pause")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "pause", event.code
        assert event.pause?

        # Kind
        assert_equal :system, event.kind
        assert event.system?
        refute event.function?
      end
    end

    # --- Pattern matching with kind ---

    def test_deconstruct_keys_includes_kind
      with_test_terminal do
        inject_keys("media_play")
        event = RatatuiRuby.poll_event

        hash = event.deconstruct_keys(nil)
        assert_equal :media, hash[:kind]
        assert_equal "media_play", hash[:code]
        assert_equal :key, hash[:type]
      end
    end

    def test_pattern_matching_on_kind
      with_test_terminal do
        inject_keys("media_play")
        event = RatatuiRuby.poll_event

        result = case event
                 in kind: :media
                   :matched_media
                 else
                   :no_match
        end

        assert_equal :matched_media, result
      end
    end

    # --- Inspect includes kind ---

    def test_inspect_includes_kind
      with_test_terminal do
        inject_keys("media_play")
        event = RatatuiRuby.poll_event

        assert_includes event.inspect, "kind=:media"
      end
    end

    # --- Default kind ---

    def test_default_kind_is_standard
      # When creating a Key directly without kind, it defaults to :standard
      key = Event::Key.new(code: "test")
      assert_equal :standard, key.kind
      assert key.standard?
    end

    # --- Alias tests ---

    def test_unmodified_is_alias_for_standard
      with_test_terminal do
        inject_keys("a")
        event = RatatuiRuby.poll_event

        # unmodified? is an alias for standard?
        assert event.standard?
        assert event.unmodified?
      end
    end

    def test_unmodified_returns_false_for_non_standard_keys
      with_test_terminal do
        inject_keys("f1")
        event = RatatuiRuby.poll_event

        refute event.standard?
        refute event.unmodified?
      end
    end
  end
end
