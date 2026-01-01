# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestConstraint < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_constraint_creation
    c1 = RatatuiRuby::Constraint.length(10)
    assert_equal :length, c1.type
    assert_equal 10, c1.value

    c2 = RatatuiRuby::Constraint.percentage(50)
    assert_equal :percentage, c2.type
    assert_equal 50, c2.value

    c3 = RatatuiRuby::Constraint.min(5)
    assert_equal :min, c3.type
    assert_equal 5, c3.value

    c4 = RatatuiRuby::Constraint.max(20)
    assert_equal :max, c4.type
    assert_equal 20, c4.value

    c5 = RatatuiRuby::Constraint.fill(3)
    assert_equal :fill, c5.type
    assert_equal 3, c5.value

    c6 = RatatuiRuby::Constraint.fill
    assert_equal :fill, c6.type
    assert_equal 1, c6.value
  end

  def test_equality
    # Data classes implement value-based equality by default
    c1 = RatatuiRuby::Constraint.percentage(50)
    c2 = RatatuiRuby::Constraint.percentage(50)
    c3 = RatatuiRuby::Constraint.percentage(25)

    assert_equal c1, c2
    refute_equal c1, c3
  end

  def test_render
    with_test_terminal(20, 10) do
      # Test Length and Percentage
      l = RatatuiRuby::Layout.new(
        direction: :vertical,
        constraints: [
          RatatuiRuby::Constraint.length(2), # Top 2 lines
          RatatuiRuby::Constraint.percentage(50), # 50% of remaining 8 = 4 lines? Or 50% of 10?
          # Ratatui constraints usually sum to 100% or take available space.
          # Let's test a simple split first.
          RatatuiRuby::Constraint.min(0), # Rest
        ],
        children: [
          RatatuiRuby::Block.new(title: "A", borders: [:all]),
          RatatuiRuby::Block.new(title: "B", borders: [:all]),
          RatatuiRuby::Block.new(title: "C", borders: [:all]),
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(l, f.area) }

      # Ratatui Layout constraint behavior:
      # Length(2) -> 2 units.
      # Percentage(50) -> 50% of the TOTAL area usually? Or remaining?
      # Usually Ratatui Layout takes constraints that should sum up to the total space if possible.
      # Let's try explicit 50/50 split to verify Percentage.

      l2 = RatatuiRuby::Layout.new(
        direction: :horizontal,
        constraints: [RatatuiRuby::Constraint.percentage(50), RatatuiRuby::Constraint.percentage(50)],
        children: [RatatuiRuby::Block.new(title: "L", borders: [:all]), RatatuiRuby::Block.new(title: "R", borders: [:all])]
      )
      RatatuiRuby.draw { |f| f.render_widget(l2, f.area) }
      # 20 width. 50% = 10.
      # Left block: 0-9. Right block: 10-19.

      assert_equal "┌L───────┐┌R───────┐", buffer_content[0]
      assert_equal "│        ││        │", buffer_content[1]
    end
  end

  def test_fill_constraint_render
    with_test_terminal(20, 4) do
      l = RatatuiRuby::Layout.new(
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.fill(1),
          RatatuiRuby::Constraint.fill(3),
        ],
        children: [
          RatatuiRuby::Paragraph.new(text: "A"),
          RatatuiRuby::Paragraph.new(text: "B"),
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(l, f.area) }
      # Fill(1) gets 5 chars, Fill(3) gets 15 chars (1:3 ratio of 20)
      assert_equal "A    B              ", buffer_content[0]
    end
  end

  def test_max_constraint_render
    with_test_terminal(20, 4) do
      l = RatatuiRuby::Layout.new(
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.max(8),
          RatatuiRuby::Constraint.fill(1),
        ],
        children: [
          RatatuiRuby::Paragraph.new(text: "Max"),
          RatatuiRuby::Paragraph.new(text: "Fill"),
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(l, f.area) }
      # Max(8) caps first at 8, Fill gets rest (12)
      assert_equal "Max     Fill        ", buffer_content[0]
    end
  end

  def test_ratio_constraint_render
    with_test_terminal(20, 4) do
      l = RatatuiRuby::Layout.new(
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.ratio(1, 4),
          RatatuiRuby::Constraint.ratio(3, 4),
        ],
        children: [
          RatatuiRuby::Paragraph.new(text: "A"),
          RatatuiRuby::Paragraph.new(text: "B"),
        ]
      )
      RatatuiRuby.draw { |f| f.render_widget(l, f.area) }
      # Ratio(1/4) of 20 = 5. Ratio(3/4) of 20 = 15.
      assert_equal "A    B              ", buffer_content[0]
    end
  end

  def test_ratio_creation
    c = RatatuiRuby::Constraint.ratio(1, 2)
    assert_equal :ratio, c.type
    assert_equal [1, 2], c.value
  end
end
