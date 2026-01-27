# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestMouse < Minitest::Test
    def test_mouse_initialization
      event = Event::Mouse.new(kind: "down", x: 10, y: 5, button: "left", modifiers: ["ctrl"])
      assert_equal "down", event.kind
      assert_equal 10, event.x
      assert_equal 5, event.y
      assert_equal "left", event.button
      assert_equal ["ctrl"], event.modifiers

      assert_predicate event, :mouse?
      refute_predicate event, :key?

      event = Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: nil)
      assert_equal "none", event.button
    end

    def test_predicates
      assert_predicate Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"), :down?
      assert_predicate Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left"), :up?
      assert_predicate Event::Mouse.new(kind: "drag", x: 0, y: 0, button: "left"), :drag?
      assert_predicate Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none"), :scroll_up?
      assert_predicate Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none"), :scroll_down?

      refute_predicate Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left"), :down?
    end

    def test_mouse_down_and_mouse_up_aliases
      down_event = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left")
      up_event = Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left")

      assert_predicate down_event, :mouse_down?
      refute_predicate down_event, :mouse_up?

      assert_predicate up_event, :mouse_up?
      refute_predicate up_event, :mouse_down?
    end

    def test_button_predicates
      left_event = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left")
      right_event = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "right")
      middle_event = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "middle")

      # Short form: left?, right?, middle?
      assert_predicate left_event, :left?
      refute_predicate left_event, :right?
      refute_predicate left_event, :middle?

      assert_predicate right_event, :right?
      refute_predicate right_event, :left?

      assert_predicate middle_event, :middle?
      refute_predicate middle_event, :left?

      # Long form: left_button?, right_button?, middle_button?
      assert_predicate left_event, :left_button?
      assert_predicate right_event, :right_button?
      assert_predicate middle_event, :middle_button?
    end

    def test_equality
      e1 = Event::Mouse.new(kind: "down", x: 1, y: 1, button: "left")
      e2 = Event::Mouse.new(kind: "down", x: 1, y: 1, button: "left")
      e3 = Event::Mouse.new(kind: "up", x: 1, y: 1, button: "left")

      assert_equal e1, e2
      refute_equal e1, e3
    end

    def test_deconstruct_keys
      event = Event::Mouse.new(kind: "down", x: 10, y: 5, button: "left")
      pattern = event.deconstruct_keys(nil)

      assert_equal :mouse, pattern[:type]
      assert_equal "down", pattern[:kind]
      assert_equal 10, pattern[:x]
      assert_equal 5, pattern[:y]
      assert_equal "left", pattern[:button]
    end

    def test_duck_typed_pattern_matching
      event = Event::Mouse.new(kind: "down", x: 10, y: 5, button: "left")
      case event
      in type: :mouse, kind: "down", x: 10, y: 5
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_exact_pattern_matching
      event = Event::Mouse.new(kind: "down", x: 10, y: 5, button: "left")
      case event
      in RatatuiRuby::Event::Mouse(kind: "down", x: 10, y: 5, button: "left")
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_symbol_comparison_left_button
      assert_operator Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"), :==, :mouse_left_down
      assert_operator Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left"), :==, :mouse_left_up
      assert_operator Event::Mouse.new(kind: "drag", x: 0, y: 0, button: "left"), :==, :mouse_left_drag
    end

    def test_symbol_comparison_right_button
      assert_operator Event::Mouse.new(kind: "down", x: 0, y: 0, button: "right"), :==, :mouse_right_down
      assert_operator Event::Mouse.new(kind: "up", x: 0, y: 0, button: "right"), :==, :mouse_right_up
      assert_operator Event::Mouse.new(kind: "drag", x: 0, y: 0, button: "right"), :==, :mouse_right_drag
    end

    def test_symbol_comparison_middle_button
      assert_operator Event::Mouse.new(kind: "down", x: 0, y: 0, button: "middle"), :==, :mouse_middle_down
      assert_operator Event::Mouse.new(kind: "up", x: 0, y: 0, button: "middle"), :==, :mouse_middle_up
      assert_operator Event::Mouse.new(kind: "drag", x: 0, y: 0, button: "middle"), :==, :mouse_middle_drag
    end

    def test_symbol_comparison_scroll
      assert_operator Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none"), :==, :scroll_up
      assert_operator Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none"), :==, :scroll_down
    end

    def test_symbol_comparison_move
      assert_operator Event::Mouse.new(kind: "moved", x: 0, y: 0, button: "none"), :==, :mouse_moved
    end

    def test_symbol_comparison_negative
      left_down = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left")
      refute_operator left_down, :==, :resize
      refute_operator left_down, :==, :mouse_right_down
      refute_operator left_down, :==, :mouse_left_up
      refute_operator left_down, :==, :scroll_up
    end

    def test_to_sym_button_events
      assert_equal :mouse_left_down, Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left").to_sym
      assert_equal :mouse_right_up, Event::Mouse.new(kind: "up", x: 0, y: 0, button: "right").to_sym
      assert_equal :mouse_middle_drag, Event::Mouse.new(kind: "drag", x: 0, y: 0, button: "middle").to_sym
    end

    def test_to_sym_scroll_events
      assert_equal :scroll_up, Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none").to_sym
      assert_equal :scroll_down, Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none").to_sym
    end

    def test_to_sym_move_events
      assert_equal :mouse_moved, Event::Mouse.new(kind: "moved", x: 0, y: 0, button: "none").to_sym
    end

    # =========================================================================
    # DWIM Predicates - Things People Might Try
    # =========================================================================

    # Wheel aliases
    def test_dwim_wheel_predicates
      scroll_up = Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none")
      scroll_down = Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none")
      left_down = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left")

      # wheel_up?/wheel_down? as aliases
      assert_predicate scroll_up, :wheel_up?
      assert_predicate scroll_down, :wheel_down?
      refute_predicate scroll_up, :wheel_down?

      # scroll? - any scroll event
      assert_predicate scroll_up, :scroll?
      assert_predicate scroll_down, :scroll?
      refute_predicate left_down, :scroll?
    end

    # Platform-neutral button names
    def test_dwim_button_aliases
      left = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left")
      right = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "right")
      middle = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "middle")

      # primary?/secondary? (convention: left=primary, right=secondary)
      assert_predicate left, :primary?
      refute_predicate right, :primary?

      assert_predicate right, :secondary?
      refute_predicate left, :secondary?

      # context_menu? - right click opens context menu
      assert_predicate right, :context_menu?
      refute_predicate left, :context_menu?

      # aux? for middle/auxiliary button
      assert_predicate middle, :aux?
      assert_predicate middle, :auxiliary?
      refute_predicate left, :aux?
    end

    # Movement predicates
    def test_dwim_movement_predicates
      moved = Event::Mouse.new(kind: "moved", x: 10, y: 10, button: "none")
      drag_left = Event::Mouse.new(kind: "drag", x: 10, y: 10, button: "left")
      down_event = Event::Mouse.new(kind: "down", x: 10, y: 10, button: "left")

      # hover?/hovering?/move? for mouse movement without button
      assert_predicate moved, :hover?
      assert_predicate moved, :hovering?
      assert_predicate moved, :move?
      assert_predicate moved, :moved?
      refute_predicate drag_left, :hover? # drag is not hover
      refute_predicate down_event, :hover?

      # dragging? as alias for drag?
      assert_predicate drag_left, :dragging?
      refute_predicate moved, :dragging?
    end

    # Release predicates
    def test_dwim_release_predicates
      up_event = Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left")
      down_event = Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left")

      # release? as alias for up?
      assert_predicate up_event, :release?
      assert_predicate up_event, :released?
      refute_predicate down_event, :release?

      # press?/pressed? as alias for down?
      assert_predicate down_event, :press?
      assert_predicate down_event, :pressed?
      refute_predicate up_event, :pressed?
    end
  end
end
