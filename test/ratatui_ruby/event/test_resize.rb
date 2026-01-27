# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestResize < Minitest::Test
    def test_initialization
      event = Event::Resize.new(width: 80, height: 24)
      assert_equal 80, event.width
      assert_equal 24, event.height
      assert_predicate event, :resize?
    end

    def test_equality
      e1 = Event::Resize.new(width: 80, height: 24)
      e2 = Event::Resize.new(width: 80, height: 24)
      e3 = Event::Resize.new(width: 100, height: 24)

      assert_equal e1, e2
      refute_equal e1, e3
    end

    def test_deconstruct_keys
      event = Event::Resize.new(width: 80, height: 24)
      pattern = event.deconstruct_keys(nil)

      assert_equal :resize, pattern[:type]
      assert_equal 80, pattern[:width]
      assert_equal 24, pattern[:height]
    end

    def test_duck_typed_pattern_matching
      event = Event::Resize.new(width: 80, height: 24)
      case event
      in type: :resize, width: 80, height: 24
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_exact_pattern_matching
      event = Event::Resize.new(width: 80, height: 24)
      case event
      in RatatuiRuby::Event::Resize(width: 80, height: 24)
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_symbol_comparison
      event = Event::Resize.new(width: 80, height: 24)
      assert_operator event, :==, :resize, "Resize event should equal :resize symbol"
      refute_operator event, :==, :mouse, "Resize event should not equal :mouse symbol"
    end

    def test_to_sym
      event = Event::Resize.new(width: 80, height: 24)
      assert_equal :resize, event.to_sym
    end

    # =========================================================================
    # DWIM Predicates - Things People Might Try
    # =========================================================================

    # The classic Unix signal name - SIGWINCH
    def test_dwim_sigwinch_alias
      event = Event::Resize.new(width: 80, height: 24)

      assert_predicate event, :sigwinch?
      assert_predicate event, :winch?
      assert_predicate event, :sig_winch?
    end

    # Alternative names people might try
    def test_dwim_resize_aliases
      event = Event::Resize.new(width: 80, height: 24)

      assert_predicate event, :terminal_resize?
      assert_predicate event, :window_resize?
      assert_predicate event, :window_change?
      assert_predicate event, :viewport_resize?
      assert_predicate event, :viewport_change?
      assert_predicate event, :size_change?
      assert_predicate event, :resized?
    end

    # Predicates for checking dimensions
    def test_dwim_dimension_predicates
      wide = Event::Resize.new(width: 200, height: 24)
      tall = Event::Resize.new(width: 80, height: 100)

      # landscape?/portrait? based on aspect ratio
      assert_predicate wide, :landscape?
      refute_predicate wide, :portrait?

      assert_predicate tall, :portrait?
      refute_predicate tall, :landscape?
    end

    # VT100 standard (80x24) predicates
    def test_dwim_vt100_predicates
      exact_vt100 = Event::Resize.new(width: 80, height: 24)
      larger = Event::Resize.new(width: 120, height: 40)
      cramped_width = Event::Resize.new(width: 60, height: 24)
      cramped_height = Event::Resize.new(width: 80, height: 20)
      cramped_both = Event::Resize.new(width: 40, height: 10)

      # vt100? - exactly 80x24
      assert_predicate exact_vt100, :vt100?
      refute_predicate larger, :vt100?
      refute_predicate cramped_width, :vt100?

      # at_least_vt100? - 80x24 or larger in BOTH dimensions
      assert_predicate exact_vt100, :at_least_vt100?
      assert_predicate larger, :at_least_vt100?
      refute_predicate cramped_width, :at_least_vt100?
      refute_predicate cramped_height, :at_least_vt100?

      # over_vt100? - larger than 80x24 in BOTH dimensions
      assert_predicate larger, :over_vt100?
      refute_predicate exact_vt100, :over_vt100?
      refute_predicate cramped_width, :over_vt100?

      # cramped?/constrained? - under standard in EITHER dimension
      assert_predicate cramped_width, :cramped?
      assert_predicate cramped_height, :cramped?
      assert_predicate cramped_both, :cramped?
      refute_predicate exact_vt100, :cramped?
      refute_predicate larger, :cramped?

      # Alias
      assert_predicate cramped_width, :constrained?
    end
  end
end
