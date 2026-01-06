# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestText < Minitest::Test
    include RatatuiRuby::TestHelper
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
      session = RatatuiRuby::TUI.new
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

    # Text::Line should be renderable directly as a widget
    def test_line_renders_directly_as_widget
      with_test_terminal(10, 1) do
        line = RatatuiRuby::Text::Line.new(
          spans: [RatatuiRuby::Text::Span.new(content: "Direct")]
        )

        # Render the line directly without wrapping in Paragraph
        RatatuiRuby.draw { |f| f.render_widget(line, f.area) }

        cell = RatatuiRuby.get_cell_at(0, 0)
        assert_equal "D", cell.char, "Text::Line should render directly as a widget"
      end
    end

    # Text::Line alignment should be respected when rendering directly
    def test_line_alignment_rendering
      with_test_terminal(10, 1) do
        # Create a centered line - "Hi" is 2 chars, so it should start at position 4 in a 10-char area
        line = RatatuiRuby::Text::Line.new(
          spans: [RatatuiRuby::Text::Span.new(content: "Hi")],
          alignment: :center
        )

        RatatuiRuby.draw { |f| f.render_widget(line, f.area) }

        # In a 10-char area, "Hi" (2 chars) centered should start at position 4
        cell_start = RatatuiRuby.get_cell_at(4, 0)
        assert_equal "H", cell_start.char, "Centered text should start at position 4"
      end
    end

    # v0.7.0: Text::Line style: parameter should be applied during rendering
    def test_line_style_rendering
      with_test_terminal(10, 1) do
        # Create a Line with line-level style (should apply to all spans)
        line = RatatuiRuby::Text::Line.new(
          spans: [RatatuiRuby::Text::Span.new(content: "Hello")],
          style: RatatuiRuby::Style::Style.new(bg: :blue)
        )

        paragraph = RatatuiRuby::Widgets::Paragraph.new(text: [line])
        RatatuiRuby.draw { |f| f.render_widget(paragraph, f.area) }

        # The line-level style should apply blue background to all cells
        cell = RatatuiRuby.get_cell_at(0, 0)
        assert_equal "H", cell.char
        assert_equal :blue, cell.bg, "Line-level style bg should be applied"
      end
    end

    # Gap tests - verify missing methods from v1.0.0_blockers.md

    # Span methods
    def test_span_width
      skip "v1.0.0 Blocker: Span#width not implemented. See doc/contributors/v1.0.0_blockers.md"
      span = RatatuiRuby::Text::Span.new(content: "Hello")
      assert_equal 5, span.width
    end

    def test_span_raw
      skip "v1.0.0 Blocker: Span.raw not implemented. See doc/contributors/v1.0.0_blockers.md"
      span = RatatuiRuby::Text::Span.raw("Hello")
      assert_equal "Hello", span.content
    end

    def test_span_patch_style
      skip "v1.0.0 Blocker: Span#patch_style not implemented. See doc/contributors/v1.0.0_blockers.md"
      span = RatatuiRuby::Text::Span.new(content: "Hello", style: RatatuiRuby::Style::Style.new(fg: :red))
      patched = span.patch_style(RatatuiRuby::Style::Style.new(bg: :blue))
      assert_equal :red, patched.style.fg
      assert_equal :blue, patched.style.bg
    end

    def test_span_reset_style
      skip "v1.0.0 Blocker: Span#reset_style not implemented. See doc/contributors/v1.0.0_blockers.md"
      span = RatatuiRuby::Text::Span.new(content: "Hello", style: RatatuiRuby::Style::Style.new(fg: :red))
      reset = span.reset_style
      assert_nil reset.style.fg
    end

    # Line methods
    def test_line_left_aligned
      skip "v1.0.0 Blocker: Line#left_aligned not implemented. See doc/contributors/v1.0.0_blockers.md"
      line = RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "Hello")])
      aligned = line.left_aligned
      assert_equal :left, aligned.alignment
    end

    def test_line_centered
      skip "v1.0.0 Blocker: Line#centered not implemented. See doc/contributors/v1.0.0_blockers.md"
      line = RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "Hello")])
      centered = line.centered
      assert_equal :center, centered.alignment
    end

    def test_line_right_aligned
      skip "v1.0.0 Blocker: Line#right_aligned not implemented. See doc/contributors/v1.0.0_blockers.md"
      line = RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "Hello")])
      aligned = line.right_aligned
      assert_equal :right, aligned.alignment
    end

    def test_line_push_span
      skip "v1.0.0 Blocker: Line#push_span not implemented. See doc/contributors/v1.0.0_blockers.md"
      line = RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "Hello")])
      new_span = RatatuiRuby::Text::Span.new(content: " World")
      line.push_span(new_span)
      assert_equal 2, line.spans.size
    end

    def test_line_patch_style
      skip "v1.0.0 Blocker: Line#patch_style not implemented. See doc/contributors/v1.0.0_blockers.md"
      line = RatatuiRuby::Text::Line.new(spans: [RatatuiRuby::Text::Span.new(content: "Hello")])
      patched = line.patch_style(RatatuiRuby::Style::Style.new(fg: :red))
      # Should apply to all spans
      assert_equal :red, patched.spans.first.style.fg
    end

    def test_line_reset_style
      skip "v1.0.0 Blocker: Line#reset_style not implemented. See doc/contributors/v1.0.0_blockers.md"
      line = RatatuiRuby::Text::Line.new(
        spans: [RatatuiRuby::Text::Span.new(content: "Hello", style: RatatuiRuby::Style::Style.new(fg: :red))]
      )
      reset = line.reset_style
      assert_nil reset.spans.first.style.fg
    end
  end
end
