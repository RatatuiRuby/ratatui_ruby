# frozen_string_literal: true

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
          RatatuiRuby::Paragraph.new(text: "Bottom")
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
end
