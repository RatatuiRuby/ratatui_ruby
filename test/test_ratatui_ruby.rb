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
    assert_nil p.fg
    assert_nil p.bg
  end

  def test_layout_creation
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    l = RatatuiRuby::Layout.new(direction: :vertical, children: [p])
    assert_equal :vertical, l.direction
    assert_equal [p], l.children
  end

  def test_layout_defaults
    l = RatatuiRuby::Layout.new
    assert_equal :vertical, l.direction
    assert_equal [], l.children
  end

  def test_nested_layout
    p = RatatuiRuby::Paragraph.new(text: "Inner")
    inner = RatatuiRuby::Layout.new(direction: :horizontal, children: [p])
    outer = RatatuiRuby::Layout.new(direction: :vertical, children: [inner])
    assert_equal [inner], outer.children
    assert_equal [p], outer.children.first.children
  end
end
