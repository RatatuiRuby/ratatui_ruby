# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestConstraint < Minitest::Test
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
      RatatuiRuby.draw(l)

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
      RatatuiRuby.draw(l2)
      # 20 width. 50% = 10.
      # Left block: 0-9. Right block: 10-19.

      assert_equal "┌L───────┐┌R───────┐", buffer_content[0]
      assert_equal "│        ││        │", buffer_content[1]
    end
  end
end
