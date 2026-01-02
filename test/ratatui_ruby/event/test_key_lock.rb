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

    LOCK_KEYS = %w[
      caps_lock
      scroll_lock
      num_lock
    ].freeze

    def test_all_lock_keys_round_trip
      with_test_terminal do
        LOCK_KEYS.each do |key|
          inject_keys(key)
          event = RatatuiRuby.poll_event
          assert_equal key, event.code,
            "Lock key '#{key}' should round-trip through FFI"
        end
      end
    end
  end
end
