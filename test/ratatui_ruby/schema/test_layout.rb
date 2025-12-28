# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestLayout < Minitest::Test
  def test_layout_creation
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    l = RatatuiRuby::Layout.new(direction: :vertical, constraints: [RatatuiRuby::Constraint.percentage(100)], children: [p])
    assert_equal :vertical, l.direction
    assert_equal 1, l.constraints.length
    assert_equal :percentage, l.constraints.first.type
    assert_equal 100, l.constraints.first.value
    assert_equal [p], l.children
  end

  def test_layout_defaults
    l = RatatuiRuby::Layout.new
    assert_equal :vertical, l.direction
    assert_equal [], l.constraints
    assert_equal [], l.children
    assert_equal :legacy, l.flex
  end

  def test_layout_with_flex
    l = RatatuiRuby::Layout.new(flex: :space_between)
    assert_equal :space_between, l.flex

    l2 = RatatuiRuby::Layout.new(flex: :center)
    assert_equal :center, l2.flex
  end

  def test_flex_modes_constant
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :legacy
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :start
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :center
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :end
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :space_between
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :space_around
  end

  def test_nested_layout
    p = RatatuiRuby::Paragraph.new(text: "Inner")
    inner = RatatuiRuby::Layout.new(direction: :horizontal, children: [p])
    outer = RatatuiRuby::Layout.new(direction: :vertical, children: [inner])
    assert_equal [inner], outer.children
    assert_equal [p], outer.children.first.children
  end

  def test_render
    with_test_terminal(20, 10) do
      l = RatatuiRuby::Layout.new(
        direction: :vertical,
        constraints: [RatatuiRuby::Constraint.percentage(50), RatatuiRuby::Constraint.percentage(50)],
        children: [
          RatatuiRuby::Paragraph.new(text: "Top"),
          RatatuiRuby::Paragraph.new(text: "Bottom"),
        ]
      )
      RatatuiRuby.draw(l)
      assert_equal "Top                 ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
      assert_equal "                    ", buffer_content[2]
      assert_equal "                    ", buffer_content[3]
      assert_equal "                    ", buffer_content[4]
      assert_equal "Bottom              ", buffer_content[5]
      assert_equal "                    ", buffer_content[6]
      assert_equal "                    ", buffer_content[7]
      assert_equal "                    ", buffer_content[8]
      assert_equal "                    ", buffer_content[9]
    end
  end

  def test_render_flex_center
    with_test_terminal(20, 3) do
      l = RatatuiRuby::Layout.new(
        direction: :horizontal,
        flex: :center,
        constraints: [RatatuiRuby::Constraint.length(6)],
        children: [RatatuiRuby::Paragraph.new(text: "Center")]
      )
      RatatuiRuby.draw(l)
      # 6 chars centered in 20: starts at position 7 (0-indexed)
      assert_equal "       Center       ", buffer_content[0]
    end
  end

  def test_render_flex_space_between
    with_test_terminal(20, 3) do
      l = RatatuiRuby::Layout.new(
        direction: :horizontal,
        flex: :space_between,
        constraints: [
          RatatuiRuby::Constraint.length(2),
          RatatuiRuby::Constraint.length(2),
          RatatuiRuby::Constraint.length(2)
        ],
        children: [
          RatatuiRuby::Paragraph.new(text: "A"),
          RatatuiRuby::Paragraph.new(text: "B"),
          RatatuiRuby::Paragraph.new(text: "C")
        ]
      )
      RatatuiRuby.draw(l)
      # Three 2-char blocks in 20 width with space_between:
      # First at 0, second at 9, third at 18
      assert_equal "A        B        C ", buffer_content[0]
    end
  end

  def test_render_flex_end
    with_test_terminal(20, 3) do
      l = RatatuiRuby::Layout.new(
        direction: :horizontal,
        flex: :end,
        constraints: [RatatuiRuby::Constraint.length(5)],
        children: [RatatuiRuby::Paragraph.new(text: "Right")]
      )
      RatatuiRuby.draw(l)
      # 5 chars aligned to end in 20: starts at position 15
      assert_equal "               Right", buffer_content[0]
    end
  end
end
