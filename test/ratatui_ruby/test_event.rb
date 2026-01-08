# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestEvent < Minitest::Test
    def setup
      @event = Event.new
    end

    def test_default_predicates
      refute_predicate @event, :none?
      refute_predicate @event, :key?
      refute_predicate @event, :mouse?
      refute_predicate @event, :resize?
      refute_predicate @event, :paste?
      refute_predicate @event, :focus_gained?
      refute_predicate @event, :focus_lost?
    end

    def test_event_none
      event = Event::None.new
      assert_predicate event, :none?
      refute_predicate event, :key?
      assert_equal({ type: :none }, event.deconstruct_keys(nil))

      # Pattern matching
      case event
      in { type: :none }
        # Success
      else
        flunk "Expected Event::None to match { type: :none }"
      end
    end

    def test_deconstruct_keys_defaults
      assert_equal({}, @event.deconstruct_keys(nil))
      assert_equal({}, @event.deconstruct_keys([]))
    end

    def test_safe_dynamic_predicates_return_false
      # Non-key events should safely respond false to any key predicate
      events = [@event, Event::None.new]
      events.each do |e|
        refute_predicate e, :ctrl_c?
        refute_predicate e, :enter?
        refute_predicate e, :q?
        refute_predicate e, :alt_shift_up?
        refute_predicate e, :f1?
      end
    end

    def test_non_key_event_with_arbitrary_predicates
      # Mouse, Resize, Paste, None, etc. should safely return false for any predicate
      mouse = Event::Mouse.new(x: 10, y: 5, kind: :down, button: nil, modifiers: [])
      refute_predicate mouse, :ctrl_c?
      refute_predicate mouse, :enter?

      resize = Event::Resize.new(width: 80, height: 24)
      refute_predicate resize, :q?
      refute_predicate resize, :tab?

      paste = Event::Paste.new(content: "hello")
      refute_predicate paste, :ctrl_a?
      refute_predicate paste, :delete?

      none = Event::None.new
      refute_predicate none, :ctrl_c?
      refute_predicate none, :enter?
    end

    def test_respond_to_missing_for_dynamic_predicates
      events = [@event, Event::None.new]
      events.each do |e|
        assert_respond_to e, :ctrl_c?
        assert_respond_to e, :arbitrary_key_name?
        refute_respond_to e, :not_a_predicate
      end
    end

    # == Event::Sync ==
    #
    # Sync is a synthetic event injected by tests. When a runtime (Tea, Kit)
    # encounters this event, it should wait for all pending async operations
    # to complete before processing the next event. This enables deterministic
    # testing of async behavior without changing production code paths.

    def test_event_sync
      event = Event::Sync.new
      assert_predicate event, :sync?
      refute_predicate event, :key?
      refute_predicate event, :none?
      assert_equal({ type: :sync }, event.deconstruct_keys(nil))

      # Pattern matching
      case event
      in { type: :sync }
        # Success
      else
        flunk "Expected Event::Sync to match { type: :sync }"
      end
    end
  end
end
