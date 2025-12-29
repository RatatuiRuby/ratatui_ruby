# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "test_helper"
require_relative "app"

class TestRichTextApp < Minitest::Test
  include RatatuiRuby::TestHelper

  include RatatuiRuby::TestHelper

  def test_simple_span
    span = RatatuiRuby::Text::Span.new(content: "hello", style: nil)
    assert_equal "hello", span.content
    assert_nil span.style
  end

  def test_styled_span
    style = RatatuiRuby::Style.new(fg: :red, modifiers: [:bold])
    span = RatatuiRuby::Text::Span.new(content: "error", style:)
    assert_equal "error", span.content
    assert_equal style, span.style
  end

  def test_span_styled_helper
    style = RatatuiRuby::Style.new(modifiers: [:italic])
    span = RatatuiRuby::Text::Span.styled("italic text", style)
    assert_equal "italic text", span.content
    assert_equal style, span.style
  end

  def test_span_styled_helper_without_style
    span = RatatuiRuby::Text::Span.styled("plain")
    assert_equal "plain", span.content
    assert_nil span.style
  end

  def test_simple_line
    spans = [
      RatatuiRuby::Text::Span.new(content: "hello", style: nil),
      RatatuiRuby::Text::Span.new(content: " world", style: nil)
    ]
    line = RatatuiRuby::Text::Line.new(spans:)
    assert_equal spans, line.spans
    assert_nil line.alignment
  end

  def test_line_with_alignment
    spans = [RatatuiRuby::Text::Span.new(content: "centered", style: nil)]
    line = RatatuiRuby::Text::Line.new(spans:, alignment: :center)
    assert_equal :center, line.alignment
  end

  def test_line_from_string
    line = RatatuiRuby::Text::Line.from_string("test content")
    assert_equal 1, line.spans.length
    assert_equal "test content", line.spans[0].content
    assert_nil line.spans[0].style
  end

  def test_line_from_string_with_alignment
    line = RatatuiRuby::Text::Line.from_string("right aligned", alignment: :right)
    assert_equal :right, line.alignment
  end

  def test_paragraph_with_string
    para = RatatuiRuby::Paragraph.new(text: "simple text")
    assert_equal "simple text", para.text
  end

  def test_paragraph_with_span
    span = RatatuiRuby::Text::Span.new(content: "bold", style: RatatuiRuby::Style.new(modifiers: [:bold]))
    para = RatatuiRuby::Paragraph.new(text: span)
    assert_equal span, para.text
  end

  def test_paragraph_with_line
    line = RatatuiRuby::Text::Line.new(
      spans: [
        RatatuiRuby::Text::Span.new(content: "hello ", style: nil),
        RatatuiRuby::Text::Span.new(content: "world", style: RatatuiRuby::Style.new(fg: :green))
      ]
    )
    para = RatatuiRuby::Paragraph.new(text: line)
    assert_equal line, para.text
  end

  def test_paragraph_with_multiple_lines
    lines = [
      RatatuiRuby::Text::Line.new(
        spans: [RatatuiRuby::Text::Span.new(content: "line 1", style: nil)]
      ),
      RatatuiRuby::Text::Line.new(
        spans: [RatatuiRuby::Text::Span.new(content: "line 2", style: RatatuiRuby::Style.new(fg: :red))]
      )
    ]
    para = RatatuiRuby::Paragraph.new(text: lines)
    assert_equal lines, para.text
  end

  def test_paragraph_renders_with_rich_text
    with_test_terminal(80, 24) do
      # Test that a paragraph with rich text can be rendered without error
      line = RatatuiRuby::Text::Line.new(
        spans: [
          RatatuiRuby::Text::Span.new(content: "normal ", style: nil),
          RatatuiRuby::Text::Span.new(content: "bold", style: RatatuiRuby::Style.new(modifiers: [:bold])),
          RatatuiRuby::Text::Span.new(content: " text", style: nil)
        ]
      )
      para = RatatuiRuby::Paragraph.new(
        text: line,
        block: RatatuiRuby::Block.new(title: "Test", borders: [:all])
      )
      # Should not raise an error when rendering
      RatatuiRuby.draw(para)
    end
  end

  def test_paragraph_renders_multiple_rich_lines
    with_test_terminal(80, 24) do
      lines = [
        RatatuiRuby::Text::Line.new(
          spans: [
            RatatuiRuby::Text::Span.new(content: "✓ ", style: RatatuiRuby::Style.new(fg: :green, modifiers: [:bold])),
            RatatuiRuby::Text::Span.new(content: "Complete", style: nil)
          ]
        ),
        RatatuiRuby::Text::Line.new(
          spans: [
            RatatuiRuby::Text::Span.new(content: "✗ ", style: RatatuiRuby::Style.new(fg: :red, modifiers: [:bold])),
            RatatuiRuby::Text::Span.new(content: "Failed", style: nil)
          ]
        )
      ]
      para = RatatuiRuby::Paragraph.new(text: lines)
      # Should not raise an error when rendering
      RatatuiRuby.draw(para)
    end
  end
end

require_relative "app"

class TestRichTextApp < Minitest::Test
  include RatatuiRuby::TestHelper

  include RatatuiRuby::TestHelper

  def test_app_runs
    with_test_terminal(80, 24) do
      inject_key(:q)
      RichTextApp.new.run
      
      assert buffer_content.any? { |line| line.include?("Simple Rich Text") }
      assert buffer_content.any? { |line| line.include?("Status Report") }
    end
  end
end



