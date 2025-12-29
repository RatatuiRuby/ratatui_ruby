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
  end
end
