# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestText < Minitest::Test
    def test_width_ascii
      # ASCII characters are 1 cell each
      assert_equal 5, RatatuiRuby::Text.width("hello")
      assert_equal 13, RatatuiRuby::Text.width("Hello, World!")
    end

    def test_width_emoji
      # Emoji are typically 2 cells each
      assert_equal 2, RatatuiRuby::Text.width("👍")
      assert_equal 2, RatatuiRuby::Text.width("🌍")
      # "Hello 👍" = 5 + space (1) + emoji (2) = 8
      assert_equal 8, RatatuiRuby::Text.width("Hello 👍")
    end

    def test_width_cjk
      # CJK characters are full-width (2 cells each)
      assert_equal 2, RatatuiRuby::Text.width("你")
      assert_equal 2, RatatuiRuby::Text.width("好")
      assert_equal 4, RatatuiRuby::Text.width("你好")
    end

    def test_width_mixed
      # Mixed content: "a你b好" = 1 + 2 + 1 + 2 = 6
      assert_equal 6, RatatuiRuby::Text.width("a你b好")
      # "Hi 你好 👍" = 2 + space + 4 + space + 2 = 10 (not 11, each char correctly counted)
      assert_equal 10, RatatuiRuby::Text.width("Hi 你好 👍")
    end

    def test_width_empty
      assert_equal 0, RatatuiRuby::Text.width("")
    end

    def test_width_spaces_and_punctuation
      # Regular ASCII space and punctuation are 1 cell each
      assert_equal 5, RatatuiRuby::Text.width("a b c")
      assert_equal 3, RatatuiRuby::Text.width("!!!")
    end

    def test_width_combining_marks
      # Zero-width combining marks don't add to width
      # "a" + combining acute accent (U+0301)
      combining = "a\u{0301}"
      assert_equal 1, RatatuiRuby::Text.width(combining)
    end

    def test_width_type_error
      # Should raise TypeError for non-string input
      assert_raises(TypeError) do
        RatatuiRuby::Text.width(123)
      end

      assert_raises(TypeError) do
        RatatuiRuby::Text.width(nil)
      end
    end

    def test_session_text_width
      # Verify Session DSL delegates text_width to RatatuiRuby::Text.width
      session = RatatuiRuby::Session.new
      assert_equal 5, session.text_width("hello")
      assert_equal 4, session.text_width("你好")
      assert_equal 8, session.text_width("Hello 👍")
    end

    # Feature 3: Line#width instance method
    def test_line_width_simple
      line = RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Hello"),
      ])
      assert_equal 5, line.width
    end

    def test_line_width_multiple_spans
      line = RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Hello "),
        RatatuiRuby::Text::Span.new(content: "World"),
      ])
      assert_equal 11, line.width
    end

    def test_line_width_with_cjk
      line = RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Hello "),
        RatatuiRuby::Text::Span.new(content: "世界"),
      ])
      # "Hello " = 6, "世界" = 4 (2 CJK × 2 cells)
      assert_equal 10, line.width
    end

    def test_line_width_empty
      line = RatatuiRuby::Text::Line.new(spans: [])
      assert_equal 0, line.width
    end

    def test_line_width_from_string
      line = RatatuiRuby::Text::Line.from_string("Test")
      assert_equal 4, line.width
    end
  end
end
