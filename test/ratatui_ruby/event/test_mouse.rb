# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
    end

    def test_predicates
      assert_predicate Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"), :down?
      assert_predicate Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left"), :up?
      assert_predicate Event::Mouse.new(kind: "drag", x: 0, y: 0, button: "left"), :drag?
      assert_predicate Event::Mouse.new(kind: "scroll_up", x: 0, y: 0, button: "none"), :scroll_up?
      assert_predicate Event::Mouse.new(kind: "scroll_down", x: 0, y: 0, button: "none"), :scroll_down?
      
      refute_predicate Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left"), :down?
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
  end
end
