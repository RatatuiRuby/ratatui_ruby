# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for system KeyCode variants through the Rust FFI layer.
  #
  # Tests: PrintScreen, Pause, Menu, KeypadBegin
  class TestKeySystem < Minitest::Test
    include RatatuiRuby::TestHelper

    SYSTEM_KEYS = %w[
      print_screen
      pause
      menu
      keypad_begin
    ].freeze

    def test_all_system_keys_round_trip
      with_test_terminal do
        SYSTEM_KEYS.each do |key|
          inject_keys(key)
          event = RatatuiRuby.poll_event
          assert_equal key, event.code,
            "System key '#{key}' should round-trip through FFI"
        end
      end
    end
  end
end
