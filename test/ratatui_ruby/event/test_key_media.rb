# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for media KeyCode variants through the Rust FFI layer.
  #
  # Tests all MediaKeyCode variants: Play, Pause (as media_pause), PlayPause,
  # Reverse, Stop, FastForward, Rewind, TrackNext, TrackPrevious, Record,
  # LowerVolume, RaiseVolume, MuteVolume.
  #
  # Note: Media(Pause) maps to "media_pause" to disambiguate from KeyCode::Pause.
  class TestKeyMedia < Minitest::Test
    include RatatuiRuby::TestHelper

    MEDIA_KEYS = %w[
      play
      media_pause
      play_pause
      reverse
      stop
      fast_forward
      rewind
      track_next
      track_previous
      record
      lower_volume
      raise_volume
      mute_volume
    ].freeze

    def test_all_media_keys_round_trip
      with_test_terminal do
        MEDIA_KEYS.each do |key|
          inject_keys(key)
          event = RatatuiRuby.poll_event
          assert_equal key, event.code,
            "Media key '#{key}' should round-trip through FFI"
        end
      end
    end

    def test_media_pause_disambiguated_from_pause
      with_test_terminal do
        inject_keys("pause")
        pause_event = RatatuiRuby.poll_event
        inject_keys("media_pause")
        media_pause_event = RatatuiRuby.poll_event

        refute_equal pause_event.code, media_pause_event.code,
          "KeyCode::Pause and Media(Pause) should map to different strings"
        assert_equal "pause", pause_event.code
        assert_equal "media_pause", media_pause_event.code
      end
    end
  end
end
