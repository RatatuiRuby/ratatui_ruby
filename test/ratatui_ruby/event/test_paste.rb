# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestPaste < Minitest::Test
    def test_initialization
      event = Event::Paste.new(content: "hello world")
      assert_equal "hello world", event.content
      assert_predicate event, :paste?
    end

    def test_equality
      e1 = Event::Paste.new(content: "abc")
      e2 = Event::Paste.new(content: "abc")
      e3 = Event::Paste.new(content: "def")

      assert_equal e1, e2
      refute_equal e1, e3
    end

    def test_deconstruct_keys
      event = Event::Paste.new(content: "hello")
      pattern = event.deconstruct_keys(nil)

      assert_equal :paste, pattern[:type]
      assert_equal "hello", pattern[:content]
    end

    def test_duck_typed_pattern_matching
      event = Event::Paste.new(content: "hello")
      case event
      in type: :paste, content: "hello"
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_exact_pattern_matching
      event = Event::Paste.new(content: "hello")
      case event
      in RatatuiRuby::Event::Paste(content: "hello")
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    # =========================================================================
    # DWIM Predicates - Things People Might Try
    # =========================================================================

    # Generic paste aliases
    def test_dwim_paste_aliases
      event = Event::Paste.new(content: "hello")

      assert_predicate event, :clipboard?
      assert_predicate event, :pasteboard? # macOS terminology
      assert_predicate event, :pasted?
    end

    # Content type predicates
    def test_dwim_content_predicates
      text_paste = Event::Paste.new(content: "hello world")
      empty_paste = Event::Paste.new(content: "")
      multiline_paste = Event::Paste.new(content: "line1\nline2")
      whitespace_paste = Event::Paste.new(content: "   ")

      # empty?
      assert_predicate empty_paste, :empty?
      refute_predicate text_paste, :empty?

      # blank? - empty or whitespace only
      assert_predicate empty_paste, :blank?
      assert_predicate whitespace_paste, :blank?
      refute_predicate text_paste, :blank?

      # multiline?
      assert_predicate multiline_paste, :multi_line?
      refute_predicate text_paste, :multi_line?
      assert_predicate multiline_paste, :multiline?
      refute_predicate text_paste, :multiline?

      # single_line?
      assert_predicate text_paste, :single_line?
      refute_predicate multiline_paste, :single_line?
      assert_predicate text_paste, :singleline?
      refute_predicate multiline_paste, :singleline?
    end
  end
end
