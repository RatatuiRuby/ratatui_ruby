# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for media KeyCode variants through the Rust FFI layer.
  #
  # Tests all MediaKeyCode variants with the consistent `media_` prefix:
  # media_play, media_pause, media_play_pause, media_reverse, media_stop,
  # media_fast_forward, media_rewind, media_track_next, media_track_previous,
  # media_record, media_lower_volume, media_raise_volume, media_mute_volume.
  #
  # Also tests the `media?` category predicate and DWIM Smart Predicates.
  class TestKeyMedia < Minitest::Test
    include RatatuiRuby::TestHelper

    def test_media_play
      with_test_terminal do
        inject_keys("media_play")
        event = RatatuiRuby.poll_event

        assert_equal "media_play", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_play?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_pause
      with_test_terminal do
        inject_keys("media_pause")
        event = RatatuiRuby.poll_event

        assert_equal "media_pause", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_pause?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_play_pause
      with_test_terminal do
        inject_keys("media_play_pause")
        event = RatatuiRuby.poll_event

        assert_equal "media_play_pause", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_play_pause?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_reverse
      with_test_terminal do
        inject_keys("media_reverse")
        event = RatatuiRuby.poll_event

        assert_equal "media_reverse", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_reverse?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_stop
      with_test_terminal do
        inject_keys("media_stop")
        event = RatatuiRuby.poll_event

        assert_equal "media_stop", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_stop?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_fast_forward
      with_test_terminal do
        inject_keys("media_fast_forward")
        event = RatatuiRuby.poll_event

        assert_equal "media_fast_forward", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_fast_forward?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_rewind
      with_test_terminal do
        inject_keys("media_rewind")
        event = RatatuiRuby.poll_event

        assert_equal "media_rewind", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_rewind?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_track_next
      with_test_terminal do
        inject_keys("media_track_next")
        event = RatatuiRuby.poll_event

        assert_equal "media_track_next", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_track_next?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_track_previous
      with_test_terminal do
        inject_keys("media_track_previous")
        event = RatatuiRuby.poll_event

        assert_equal "media_track_previous", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_track_previous?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_record
      with_test_terminal do
        inject_keys("media_record")
        event = RatatuiRuby.poll_event

        assert_equal "media_record", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_record?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_lower_volume
      with_test_terminal do
        inject_keys("media_lower_volume")
        event = RatatuiRuby.poll_event

        assert_equal "media_lower_volume", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_lower_volume?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_raise_volume
      with_test_terminal do
        inject_keys("media_raise_volume")
        event = RatatuiRuby.poll_event

        assert_equal "media_raise_volume", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_raise_volume?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_media_mute_volume
      with_test_terminal do
        inject_keys("media_mute_volume")
        event = RatatuiRuby.poll_event

        assert_equal "media_mute_volume", event.code
        assert_equal :media, event.kind
        refute event.text?
        assert_equal "", event.char

        assert event.media_mute_volume?
        assert event.media?
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    # --- DWIM Smart Predicate Tests ---

    def test_smart_predicate_pause_matches_media_pause
      with_test_terminal do
        inject_keys("media_pause")
        event = RatatuiRuby.poll_event

        # The DWIM predicate pause? should match media_pause
        assert event.pause?, "pause? should return true for media_pause (DWIM behavior)"
        # The exact predicate should also work
        assert event.media_pause?
      end
    end

    def test_smart_predicate_play_matches_media_play
      with_test_terminal do
        inject_keys("media_play")
        event = RatatuiRuby.poll_event

        # The DWIM predicate play? should match media_play
        assert event.play?, "play? should return true for media_play (DWIM behavior)"
        # The exact predicate should also work
        assert event.media_play?
      end
    end

    def test_smart_predicate_stop_matches_media_stop
      with_test_terminal do
        inject_keys("media_stop")
        event = RatatuiRuby.poll_event

        # The DWIM predicate stop? should match media_stop
        assert event.stop?, "stop? should return true for media_stop (DWIM behavior)"
        assert event.media_stop?
      end
    end

    def test_smart_predicate_record_matches_media_record
      with_test_terminal do
        inject_keys("media_record")
        event = RatatuiRuby.poll_event

        # The DWIM predicate record? should match media_record
        assert event.record?, "record? should return true for media_record (DWIM behavior)"
        assert event.media_record?
      end
    end

    # --- Disambiguation Tests ---

    def test_media_pause_disambiguated_from_system_pause
      with_test_terminal do
        inject_keys("pause")
        system_pause_event = RatatuiRuby.poll_event
        inject_keys("media_pause")
        media_pause_event = RatatuiRuby.poll_event

        # Codes are different
        refute_equal system_pause_event.code, media_pause_event.code
        assert_equal "pause", system_pause_event.code
        assert_equal "media_pause", media_pause_event.code

        # Kinds are different
        assert_equal :system, system_pause_event.kind
        assert_equal :media, media_pause_event.kind

        # Category predicates work correctly
        assert system_pause_event.system?
        refute system_pause_event.media?
        assert media_pause_event.media?
        refute media_pause_event.system?

        # DWIM: pause? works for BOTH (this is the key feature!)
        assert system_pause_event.pause?, "pause? should match system pause"
        assert media_pause_event.pause?, "pause? should match media_pause (DWIM)"

        # Strict predicates disambiguate
        refute system_pause_event.media_pause?
        assert media_pause_event.media_pause?
      end
    end

    # --- Category predicate tests ---

    def test_media_keys_are_not_other_categories
      with_test_terminal do
        inject_keys("media_play")
        event = RatatuiRuby.poll_event

        assert event.media?
        refute event.standard?
        refute event.function?
        refute event.modifier?
        refute event.system?
      end
    end
  end
end
