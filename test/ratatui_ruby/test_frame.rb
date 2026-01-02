# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestFrame < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_draw_with_block_yields_frame
    with_test_terminal(80, 24) do
      yielded_frame = nil

      RatatuiRuby.draw do |frame|
        yielded_frame = frame
      end

      assert_instance_of RatatuiRuby::Frame, yielded_frame
    end
  end

  def test_frame_area_returns_rect
    with_test_terminal(80, 24) do
      RatatuiRuby.draw do |frame|
        area = frame.area

        assert_instance_of RatatuiRuby::Rect, area
        assert_equal 0, area.x
        assert_equal 0, area.y
        assert_equal 80, area.width
        assert_equal 24, area.height
      end
    end
  end

  def test_frame_area_reflects_terminal_dimensions
    with_test_terminal(40, 10) do
      RatatuiRuby.draw do |frame|
        area = frame.area

        assert_equal 40, area.width
        assert_equal 10, area.height
      end
    end
  end

  def test_frame_render_widget_renders_to_specified_area
    with_test_terminal(20, 5) do
      paragraph = RatatuiRuby::Paragraph.new(text: "Hello")
      area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 1)

      RatatuiRuby.draw do |frame|
        frame.render_widget(paragraph, area)
      end

      assert_includes buffer_content.first, "Hello"
    end
  end

  def test_frame_render_widget_respects_area_position
    with_test_terminal(20, 5) do
      paragraph = RatatuiRuby::Paragraph.new(text: "X")
      # Render at position (5, 2)
      area = RatatuiRuby::Rect.new(x: 5, y: 2, width: 1, height: 1)

      RatatuiRuby.draw do |frame|
        frame.render_widget(paragraph, area)
      end

      # Check that row 2 has content at position 5
      row2 = buffer_content[2]
      assert_equal "X", row2[5]
    end
  end

  def test_frame_render_widget_multiple_widgets
    with_test_terminal(20, 3) do
      left_widget = RatatuiRuby::Paragraph.new(text: "LEFT")
      right_widget = RatatuiRuby::Paragraph.new(text: "RIGHT")

      left_area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 1)
      right_area = RatatuiRuby::Rect.new(x: 10, y: 0, width: 10, height: 1)

      RatatuiRuby.draw do |frame|
        frame.render_widget(left_widget, left_area)
        frame.render_widget(right_widget, right_area)
      end

      first_row = buffer_content.first
      assert_includes first_row, "LEFT"
      assert_includes first_row, "RIGHT"
    end
  end

  def test_legacy_draw_with_tree_still_works
    with_test_terminal(20, 5) do
      paragraph = RatatuiRuby::Paragraph.new(text: "Legacy mode")

      RatatuiRuby.draw(paragraph)

      assert_includes buffer_content.first, "Legacy mode"
    end
  end

  def test_draw_without_args_or_block_raises_error
    with_test_terminal(20, 5) do
      error = assert_raises(ArgumentError) do
        RatatuiRuby.draw
      end

      assert_match(/must provide either a tree or a block/i, error.message)
    end
  end

  def test_draw_with_both_tree_and_block_raises_error
    with_test_terminal(20, 5) do
      paragraph = RatatuiRuby::Paragraph.new(text: "Test")

      error = assert_raises(ArgumentError) do
        RatatuiRuby.draw(paragraph) { |_frame| nil } # intentionally empty block
      end

      assert_match(/cannot provide both a tree and a block/i, error.message)
    end
  end

  def test_draw_with_too_many_arguments_raises_error
    with_test_terminal(20, 5) do
      error = assert_raises(ArgumentError) do
        RatatuiRuby.draw("arg1", "arg2")
      end

      assert_match(/wrong number of arguments/, error.message)
    end
  end

  def test_frame_render_widget_returns_nil
    with_test_terminal(20, 5) do
      paragraph = RatatuiRuby::Paragraph.new(text: "Test")
      area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 10, height: 1)

      result = nil
      RatatuiRuby.draw do |frame|
        result = frame.render_widget(paragraph, area)
      end

      assert_nil result
    end
  end

  def test_frame_works_when_passed_to_helper_method
    # Passing frame to helper methods during the draw block is valid.
    with_test_terminal(20, 5) do
      RatatuiRuby.draw do |frame|
        # Simulate passing to a helper method
        result = render_paragraph_helper(frame, "Hello")
        assert_nil result # render_widget returns nil
      end

      assert_includes buffer_content.first, "Hello"
    end
  end

  private def render_paragraph_helper(frame, text)
    paragraph = RatatuiRuby::Paragraph.new(text:)
    frame.render_widget(paragraph, frame.area)
  end
end
