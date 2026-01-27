# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

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

    # =========================================================================
    # DWIM Predicates - Things People Might Try
    # =========================================================================

    # Generic focus predicates
    def test_dwim_focus_aliases
      event = Event::FocusGained.new

      # focus? - generic "something about focus"
      assert_predicate event, :focus?
      assert_predicate event, :focused?

      # gained?/lost? - the action
      assert_predicate event, :gained?
      refute_predicate event, :lost?
    end

    # Opposite of blur
    def test_dwim_blur_negative
      event = Event::FocusGained.new

      refute_predicate event, :blur?
      refute_predicate event, :blurred?
    end

    # Active/foreground terminology
    def test_dwim_activity_state
      event = Event::FocusGained.new

      assert_predicate event, :active?
      assert_predicate event, :foreground?

      refute_predicate event, :inactive?
      refute_predicate event, :background?
    end
  end
end
