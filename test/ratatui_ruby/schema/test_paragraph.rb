# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestParagraph < Minitest::Test
    include RatatuiRuby::TestHelper
  def test_paragraph_creation
    p = RatatuiRuby::Paragraph.new(text: "Hello", fg: "red", bg: "black")
    assert_equal "Hello", p.text
    assert_equal "red", p.style.fg
    assert_equal "black", p.style.bg
  end

  def test_paragraph_defaults
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    assert_equal "Hello", p.text
    assert_nil p.style.fg
    assert_nil p.style.bg
    assert_equal [], p.style.modifiers
    assert_nil p.block
  end

  def test_render
    with_test_terminal(20, 3) do
      p = RatatuiRuby::Paragraph.new(text: "Hello World")
      RatatuiRuby.draw(p)
      assert_equal "Hello World         ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
    end
  end
end
