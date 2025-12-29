# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
  end
end
