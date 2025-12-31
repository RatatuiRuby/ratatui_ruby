# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestEvent < Minitest::Test
    def setup
      @event = Event.new
    end

    def test_default_predicates
      refute_predicate @event, :key?
      refute_predicate @event, :mouse?
      refute_predicate @event, :resize?
      refute_predicate @event, :paste?
      refute_predicate @event, :focus_gained?
      refute_predicate @event, :focus_lost?
    end

    def test_deconstruct_keys_defaults
      assert_equal({}, @event.deconstruct_keys(nil))
      assert_equal({}, @event.deconstruct_keys([]))
    end

    def test_safe_dynamic_predicates_return_false
      # Non-key events should safely respond false to any key predicate
      refute_predicate @event, :ctrl_c?
      refute_predicate @event, :enter?
      refute_predicate @event, :q?
      refute_predicate @event, :alt_shift_up?
      refute_predicate @event, :f1?
    end

    def test_non_key_event_with_arbitrary_predicates
      # Mouse, Resize, Paste, etc. should safely return false for any predicate
      mouse = Event::Mouse.new(x: 10, y: 5, kind: :down, button: nil, modifiers: [])
      refute_predicate mouse, :ctrl_c?
      refute_predicate mouse, :enter?

      resize = Event::Resize.new(width: 80, height: 24)
      refute_predicate resize, :q?
      refute_predicate resize, :tab?

      paste = Event::Paste.new(content: "hello")
      refute_predicate paste, :ctrl_a?
      refute_predicate paste, :delete?
    end

    def test_respond_to_missing_for_dynamic_predicates
      assert_respond_to @event, :ctrl_c?
      assert_respond_to @event, :arbitrary_key_name?
      refute_respond_to @event, :not_a_predicate
    end
  end
end
