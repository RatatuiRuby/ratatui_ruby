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
      RatatuiRuby.draw { |f| f.render_widget(p, f.area) }
      assert_equal "Hello World         ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
    end
  end

  def test_metrics_experimental_warning
    # Temporarily enable warnings for this test
    RatatuiRuby.experimental_warnings = true
    RatatuiRuby.instance_variable_set(:@warned_features, {})

    p = RatatuiRuby::Paragraph.new(text: "Hello")
    assert_output(nil, /WARNING: Paragraph#line_count is an experimental feature/) do
      p.line_count(100)
    end
  ensure
    RatatuiRuby.experimental_warnings = false
  end

  def test_metrics_unwrapped
    p = RatatuiRuby::Paragraph.new(text: "Hello World")

    # 1 line, 11 wide
    assert_equal 1, p.line_count(100)
    assert_equal 11, p.line_width
  end

  def test_metrics_wrapped
    # "Hello World" (11 chars). Wrap at width 6.
    # "Hello" (5) fits. " " (1) fits. "World" (5) -> next line?
    # Usually "Hello " (6) fits. "World" (5) fits.
    p = RatatuiRuby::Paragraph.new(text: "Hello World", wrap: { trim: true })

    assert_equal 2, p.line_count(6)
  end

  def test_metrics_with_block
    # Borders add +2 width and +2 height.
    # This test proves we are using Ratatui's native logic.
    # A pure Ruby implementation counting string lines/chars would fail here (returning 1 and 5).
    p = RatatuiRuby::Paragraph.new(
      text: "Hello",
      block: RatatuiRuby::Block.new(borders: [:all])
    )

    # Text: 1 line, 5 wide.
    # Total: 1+2 = 3 lines. 5+2 = 7 wide.
    assert_equal 3, p.line_count(100)
    assert_equal 7, p.line_width
  end

  def test_metrics_cjk
    # "あ" is width 2 (East Asian Wide).
    p_cjk = RatatuiRuby::Paragraph.new(text: "あ")
    assert_equal 2, p_cjk.line_width
  end

  def test_metrics_emoji
    # 👨‍👩‍👧‍👦 (Family: Man, Woman, Girl, Boy) - ZWJ sequence.
    # Should render as 1 glyph (width 2?).
    # Note: Terminal rendering of emojis varies, but Ratatui uses unicode-width crate.
    # We just want to ensure it handles it logically vs string length.
    emoji = "👨‍👩‍👧‍👦"
    p_emoji = RatatuiRuby::Paragraph.new(text: emoji)
    # The string length is large (multiple codepoints). Display width is small.
    assert p_emoji.line_width < emoji.length, "Display width should be smaller than byte/char length for ZWJ emoji"
  end
end
