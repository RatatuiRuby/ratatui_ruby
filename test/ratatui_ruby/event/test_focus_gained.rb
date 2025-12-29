# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestFocusGained < Minitest::Test
    def test_initialization
      event = Event::FocusGained.new
      assert_predicate event, :focus_gained?
      refute_predicate event, :focus_lost?
    end

    def test_equality
      e1 = Event::FocusGained.new
      e2 = Event::FocusGained.new
      
      assert_equal e1, e2
    end

    def test_deconstruct_keys
      event = Event::FocusGained.new
      pattern = event.deconstruct_keys(nil)
      
      assert_equal :focus_gained, pattern[:type]
    end

    def test_duck_typed_pattern_matching
      event = Event::FocusGained.new
      case event
      in type: :focus_gained
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_exact_pattern_matching
      event = Event::FocusGained.new
      case event
      in RatatuiRuby::Event::FocusGained
        assert true
      else
        flunk "Pattern match failed"
      end
    end
  end
end
