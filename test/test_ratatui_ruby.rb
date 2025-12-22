# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestRatatuiRuby < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RatatuiRuby::VERSION
  end

  def test_paragraph_creation
    p = RatatuiRuby::Paragraph.new(text: "Hello", fg: "red", bg: "black")
    assert_equal "Hello", p.text
    assert_equal "red", p.fg
    assert_equal "black", p.bg
  end

  def test_paragraph_defaults
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    assert_equal "Hello", p.text
    assert_equal :reset, p.fg
    assert_equal :reset, p.bg
    assert_nil p.block
  end

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
  end

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

  def test_list_creation
    items = ["a", "b"]
    list = RatatuiRuby::List.new(items: items, selected_index: 1)
    assert_equal items, list.items
    assert_equal 1, list.selected_index
  end

  def test_list_defaults
    list = RatatuiRuby::List.new
    assert_equal [], list.items
    assert_nil list.selected_index
    assert_nil list.block
  end

  def test_nested_layout
    p = RatatuiRuby::Paragraph.new(text: "Inner")
    inner = RatatuiRuby::Layout.new(direction: :horizontal, children: [p])
    outer = RatatuiRuby::Layout.new(direction: :vertical, children: [inner])
    assert_equal [inner], outer.children
    assert_equal [p], outer.children.first.children
  end

  def test_block_creation
    b = RatatuiRuby::Block.new(title: "Title", borders: [:top, :bottom], border_color: "red")
    assert_equal "Title", b.title
    assert_equal [:top, :bottom], b.borders
    assert_equal "red", b.border_color
  end

  def test_block_defaults
    b = RatatuiRuby::Block.new
    assert_nil b.title
    assert_equal [:all], b.borders
    assert_nil b.border_color
  end
end
