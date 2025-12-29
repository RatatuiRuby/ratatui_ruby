# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestFocusLost < Minitest::Test
    def test_initialization
      event = Event::FocusLost.new
      assert_predicate event, :focus_lost?
      refute_predicate event, :focus_gained?
    end

    def test_equality
      e1 = Event::FocusLost.new
      e2 = Event::FocusLost.new
      
      assert_equal e1, e2
    end

    def test_deconstruct_keys
      event = Event::FocusLost.new
      pattern = event.deconstruct_keys(nil)
      
      assert_equal :focus_lost, pattern[:type]
    end

    def test_duck_typed_pattern_matching
      event = Event::FocusLost.new
      case event
      in type: :focus_lost
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_exact_pattern_matching
      event = Event::FocusLost.new
      case event
      in RatatuiRuby::Event::FocusLost
        assert true
      else
        flunk "Pattern match failed"
      end
    end
  end
end
