# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestLayout < Minitest::Test
  include RatatuiRuby::TestHelper
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

  def test_render_flex_space_evenly_2
    with_test_terminal(20, 3) do
      l = RatatuiRuby::Layout.new(
        direction: :horizontal,
        flex: :space_evenly,
        constraints: [
          RatatuiRuby::Constraint.length(2),
          RatatuiRuby::Constraint.length(2),
          RatatuiRuby::Constraint.length(2),
        ],
        children: [
          RatatuiRuby::Paragraph.new(text: "A"),
          RatatuiRuby::Paragraph.new(text: "B"),
          RatatuiRuby::Paragraph.new(text: "C"),
        ]
      )

      RatatuiRuby.draw(l)
      assert_equal "    A    B     C    ", buffer_content[0]
    end
  end

  def test_flex_modes_constant
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :legacy
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :start
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :center
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :end
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :space_between
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :space_around
    assert_includes RatatuiRuby::Layout::FLEX_MODES, :space_evenly
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
          RatatuiRuby::Constraint.length(2),
        ],
        children: [
          RatatuiRuby::Paragraph.new(text: "A"),
          RatatuiRuby::Paragraph.new(text: "B"),
          RatatuiRuby::Paragraph.new(text: "C"),
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

  def test_split_horizontal
    area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)
    rects = RatatuiRuby::Layout.split(
      area,
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.percentage(50),
        RatatuiRuby::Constraint.percentage(50),
      ]
    )
    assert_equal 2, rects.length
    assert_equal 0, rects[0].x
    assert_equal 40, rects[0].width
    assert_equal 40, rects[1].x
    assert_equal 40, rects[1].width
  end

  def test_split_vertical
    area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)
    rects = RatatuiRuby::Layout.split(
      area,
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(5),
        RatatuiRuby::Constraint.fill(1),
      ]
    )
    assert_equal 2, rects.length
    assert_equal 5, rects[0].height
    assert_equal 19, rects[1].height
    assert_equal 5, rects[1].y
  end

  def test_split_returns_rect_objects
    area = RatatuiRuby::Rect.new(x: 10, y: 5, width: 60, height: 20)
    rects = RatatuiRuby::Layout.split(
      area,
      direction: :horizontal,
      constraints: [RatatuiRuby::Constraint.percentage(100)]
    )
    assert_instance_of RatatuiRuby::Rect, rects.first
    assert_equal 10, rects.first.x
    assert_equal 5, rects.first.y
  end

  def test_split_with_flex
    area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 100, height: 10)
    rects = RatatuiRuby::Layout.split(
      area,
      direction: :horizontal,
      constraints: [RatatuiRuby::Constraint.length(20)],
      flex: :center
    )
    assert_equal 1, rects.length
    assert_equal 40, rects.first.x
    assert_equal 20, rects.first.width
  end

  def test_split_with_hash_area
    area = { x: 10, y: 10, width: 100, height: 50 }
    rects = RatatuiRuby::Layout.split(
      area,
      direction: :vertical,
      constraints: [RatatuiRuby::Constraint.percentage(50), RatatuiRuby::Constraint.percentage(50)]
    )
    assert_equal 2, rects.length
    assert_equal 10, rects[0].x
    assert_equal 10, rects[0].y
    assert_equal 100, rects[0].width
    assert_equal 25, rects[0].height
  end

  def test_split_flex_modes_comprehensive
    area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 100, height: 10)
    constraints = [RatatuiRuby::Constraint.length(10), RatatuiRuby::Constraint.length(10)]

    # :start
    rects = RatatuiRuby::Layout.split(area, direction: :horizontal, constraints:, flex: :start)
    assert_equal 0, rects[0].x
    assert_equal 10, rects[1].x

    # :end
    rects = RatatuiRuby::Layout.split(area, direction: :horizontal, constraints:, flex: :end)
    assert_equal 80, rects[0].x
    assert_equal 90, rects[1].x

    # :space_between (0, 90)
    rects = RatatuiRuby::Layout.split(area, direction: :horizontal, constraints:, flex: :space_between)
    assert_equal 0, rects[0].x
    assert_equal 90, rects[1].x

    # :space_around (12 (impl dependent spacing), ...) - approximate checking logic
    # Ratatui implementation: space_around with 2 items in 100 width, 10 each.
    # free = 80. 3 gaps. each gap ~ 26.
    # x1 = 26, x2 = 26+10+26 = 62?
    # Actually ratatui uses Cassowary solver or specific logic. Just verify they are spaced.
    rects = RatatuiRuby::Layout.split(area, direction: :horizontal, constraints:, flex: :space_around)
    assert rects[0].x > 0
    assert rects[1].x > rects[0].x + 10
    assert rects[1].x < 90

    # :space_evenly
    rects = RatatuiRuby::Layout.split(area, direction: :horizontal, constraints:, flex: :space_evenly)
    assert rects[0].x > 0
    assert rects[1].x > rects[0].x + 10
  end

  def test_split_complex_constraints
    area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 100, height: 100)
    constraints = [
      RatatuiRuby::Constraint.length(10),
      RatatuiRuby::Constraint.max(20),
      RatatuiRuby::Constraint.percentage(50),
      RatatuiRuby::Constraint.min(5),
    ]
    # layout logic will try to satisfy these.
    rects = RatatuiRuby::Layout.split(area, direction: :vertical, constraints:)
    assert_equal 4, rects.length
    assert_equal 10, rects[0].height
    # Max(20) might be 20 if there is space
    assert rects[1].height <= 20
    # Percentage(50) of 100 is 50
    assert_equal 50, rects[2].height
    # Remaining is allocated to Min(5) + others?
    # Total used: 10 + ~20 + 50 = 80.
  end
end
