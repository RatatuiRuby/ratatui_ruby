# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for simple KeyCode variants through the Rust FFI layer.
  #
  # Tests: Backspace, Enter, Left, Right, Up, Down, Home, End, PageUp, PageDown,
  # Tab, BackTab, Delete, Insert, Null, Esc
  class TestKeySimple < Minitest::Test
    include RatatuiRuby::TestHelper

    SIMPLE_KEYS = %w[
      backspace
      enter
      left
      right
      up
      down
      home
      end
      page_up
      page_down
      tab
      back_tab
      delete
      insert
      null
      esc
    ].freeze

    def test_all_simple_keys_round_trip
      with_test_terminal do
        SIMPLE_KEYS.each do |key|
          inject_keys(key)
          event = RatatuiRuby.poll_event
          assert_equal key, event.code,
            "Simple key '#{key}' should round-trip through FFI"
        end
      end
    end

    def test_simple_keys_with_ctrl_modifier
      with_test_terminal do
        %w[home end page_up page_down insert delete].each do |key|
          inject_event(RatatuiRuby::Event::Key.new(code: key, modifiers: ["ctrl"]))
          event = RatatuiRuby.poll_event
          assert_equal key, event.code
          assert_includes event.modifiers, "ctrl", "Ctrl should be preserved for #{key}"
        end
      end
    end

    def test_arrow_keys_with_shift_modifier
      with_test_terminal do
        %w[up down left right].each do |key|
          inject_event(RatatuiRuby::Event::Key.new(code: key, modifiers: ["shift"]))
          event = RatatuiRuby.poll_event
          assert_equal key, event.code
          assert_includes event.modifiers, "shift", "Shift should be preserved for #{key}"
        end
      end
    end

    def test_multiple_modifiers_preserved
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "delete", modifiers: %w[ctrl alt shift]))
        event = RatatuiRuby.poll_event
        assert_equal "delete", event.code
        assert_includes event.modifiers, "ctrl"
        assert_includes event.modifiers, "alt"
        assert_includes event.modifiers, "shift"
      end
    end
  end
end
