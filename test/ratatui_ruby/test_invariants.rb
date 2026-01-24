# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

# Tests for terminal operations during draw blocks.
#
# These tests verify that:
# 1. READ operations work during draw (via snapshot)
# 2. WRITE operations raise Error::Invariant during draw
#
# The snapshot pattern prevents reentrancy issues. Reads query the snapshot;
# writes are rejected because the terminal is borrowed during draw().
class TestInvariants < Minitest::Test
  include RatatuiRuby::TestHelper

  # === READ OPERATIONS (should work during draw) ===

  def test_viewport_area_inside_draw_works
    with_test_terminal(80, 24, timeout: 2) do
      area = nil
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          area = tui.viewport_area
        end
        break
      end
      assert_instance_of RatatuiRuby::Layout::Rect, area
      assert_equal 80, area.width
      assert_equal 24, area.height
    end
  end

  def test_terminal_size_inside_draw_works
    with_test_terminal(80, 24) do
      size = nil
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          size = RatatuiRuby.terminal_size
        end
        break
      end
      assert_instance_of RatatuiRuby::Layout::Rect, size
      assert_equal 80, size.width
      assert_equal 24, size.height
    end
  end

  def test_get_cell_at_inside_draw_works
    with_test_terminal(80, 24) do
      cell = nil
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          cell = RatatuiRuby.get_cell_at(0, 0)
        end
        break
      end
      assert_instance_of RatatuiRuby::Buffer::Cell, cell
    end
  end

  def test_poll_event_inside_draw_works
    with_test_terminal(80, 24) do
      event = nil
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          event = RatatuiRuby.poll_event(timeout: 0.0)
        end
        break
      end
      # In test mode with no events, should return None
      assert_instance_of RatatuiRuby::Event::None, event
    end
  end

  def test_inject_test_event_inside_draw_works
    with_test_terminal(80, 24) do
      event = nil
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          RatatuiRuby.inject_test_event("key", code: "x")
          event = RatatuiRuby.poll_event(timeout: 0.0)
        end
        break
      end
      assert_instance_of RatatuiRuby::Event::Key, event
      assert_equal "x", event.code
    end
  end

  def test_get_viewport_type_inside_draw_works
    with_test_terminal(80, 24) do
      viewport_type = nil
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          viewport_type = RatatuiRuby._get_viewport_type
        end
        break
      end
      assert_kind_of String, viewport_type
    end
  end

  def test_get_cursor_position_inside_draw_works
    with_test_terminal(80, 24) do
      RatatuiRuby.set_cursor_position(10, 15)
      cursor = :not_called
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          cursor = RatatuiRuby.get_cursor_position
        end
        break
      end
      # Returns the cursor position set before draw
      assert_equal [10, 15], cursor
    end
  end

  # === WRITE OPERATIONS (should raise Error::Invariant during draw) ===

  def test_insert_before_inside_draw_raises_invariant
    with_test_terminal(80, 24) do
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          assert_raises(RatatuiRuby::Error::Invariant) do
            RatatuiRuby._insert_before(1, tui.paragraph(text: "test"))
          end
        end
        break
      end
    end
  end

  def test_set_cursor_position_inside_draw_raises_invariant
    with_test_terminal(80, 24) do
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          assert_raises(RatatuiRuby::Error::Invariant) do
            RatatuiRuby.set_cursor_position(5, 5)
          end
        end
        break
      end
    end
  end

  def test_resize_terminal_inside_draw_raises_invariant
    with_test_terminal(80, 24) do
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          assert_raises(RatatuiRuby::Error::Invariant) do
            RatatuiRuby.resize_terminal(100, 50)
          end
        end
        break
      end
    end
  end

  def test_draw_inside_draw_raises_invariant
    with_test_terminal(80, 24) do
      RatatuiRuby.run do |tui|
        tui.draw do |_frame|
          # Nested draw is an invariant violation
          assert_raises(RatatuiRuby::Error::Invariant) do
            tui.draw(tui.paragraph(text: "nested"))
          end
        end
        break
      end
    end
  end
end
