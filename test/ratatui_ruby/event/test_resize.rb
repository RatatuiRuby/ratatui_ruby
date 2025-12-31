# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestResize < Minitest::Test
    def test_initialization
      event = Event::Resize.new(width: 80, height: 24)
      assert_equal 80, event.width
      assert_equal 24, event.height
      assert_predicate event, :resize?
    end

    def test_equality
      e1 = Event::Resize.new(width: 80, height: 24)
      e2 = Event::Resize.new(width: 80, height: 24)
      e3 = Event::Resize.new(width: 100, height: 24)

      assert_equal e1, e2
      refute_equal e1, e3
    end

    def test_deconstruct_keys
      event = Event::Resize.new(width: 80, height: 24)
      pattern = event.deconstruct_keys(nil)

      assert_equal :resize, pattern[:type]
      assert_equal 80, pattern[:width]
      assert_equal 24, pattern[:height]
    end

    def test_duck_typed_pattern_matching
      event = Event::Resize.new(width: 80, height: 24)
      case event
      in type: :resize, width: 80, height: 24
        assert true
      else
        flunk "Pattern match failed"
      end
    end

    def test_exact_pattern_matching
      event = Event::Resize.new(width: 80, height: 24)
      case event
      in RatatuiRuby::Event::Resize(width: 80, height: 24)
        assert true
      else
        flunk "Pattern match failed"
      end
    end
  end
end
