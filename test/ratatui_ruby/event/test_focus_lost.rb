# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

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

    # =========================================================================
    # DWIM Predicates - Things People Might Try
    # =========================================================================

    # Blur terminology (from web/GUI world)
    def test_dwim_blur_aliases
      event = Event::FocusLost.new

      assert_predicate event, :blur?
      assert_predicate event, :blurred?
      assert_predicate event, :lost?
      assert_predicate event, :unfocused?
    end

    # Opposite of focus_gained - shouldn't match focus?
    def test_dwim_focus_negative
      event = Event::FocusLost.new

      # focus? should only be true for FocusGained
      refute_predicate event, :focus?
      refute_predicate event, :focused?
      refute_predicate event, :gained?
    end

    # Inactive/background terminology
    def test_dwim_activity_state
      event = Event::FocusLost.new

      assert_predicate event, :inactive?
      assert_predicate event, :background?

      refute_predicate event, :active?
      refute_predicate event, :foreground?
    end
  end
end
