# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for function KeyCode variants through the Rust FFI layer.
  #
  # Tests: F(1) through F(24) and extended function keys up to F(255).
  class TestKeyFunction < Minitest::Test
    include RatatuiRuby::TestHelper

    FUNCTION_KEYS = (1..24).map { |n| "f#{n}" }.freeze

    def test_all_standard_function_keys_round_trip
      with_test_terminal do
        FUNCTION_KEYS.each do |key|
          inject_keys(key)
          event = RatatuiRuby.poll_event
          assert_equal key, event.code,
            "Function key '#{key}' should round-trip through FFI"
        end
      end
    end

    def test_extended_function_keys_round_trip
      with_test_terminal do
        [100, 200, 255].each do |n|
          key = "f#{n}"
          inject_keys(key)
          event = RatatuiRuby.poll_event
          assert_equal key, event.code,
            "Extended function key '#{key}' should round-trip through FFI"
        end
      end
    end

    def test_function_keys_with_alt_modifier
      with_test_terminal do
        %w[f1 f5 f12].each do |key|
          inject_event(RatatuiRuby::Event::Key.new(code: key, modifiers: ["alt"]))
          event = RatatuiRuby.poll_event
          assert_equal key, event.code
          assert_includes event.modifiers, "alt", "Alt should be preserved for #{key}"
        end
      end
    end
  end
end
