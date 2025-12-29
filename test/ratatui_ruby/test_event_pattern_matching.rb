# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestEventPatternMatching < Minitest::Test
  def test_pattern_match_key_event
    event = RatatuiRuby::Event::Key.new(code: "c", modifiers: ["ctrl"])

    matched = false
    case event
    in RatatuiRuby::Event::Key(code: "c", modifiers: ["ctrl"])
      matched = true
    else
      matched = false
    end

    assert matched, "Should match Event::Key with code and modifiers"
  end

  def test_pattern_match_mouse_event
    event = RatatuiRuby::Event::Mouse.new(kind: "down", x: 10, y: 20, button: "left", modifiers: [])

    matched = false
    case event
    in RatatuiRuby::Event::Mouse(kind: "down", x: x, y: y)
      matched = true
      assert_equal 10, x
      assert_equal 20, y
    else
      matched = false
    end

    assert matched, "Should match Event::Mouse and bind variables"
  end

  def test_pattern_match_resize_event
    event = RatatuiRuby::Event::Resize.new(width: 80, height: 24)

    matched = false
    case event
    in RatatuiRuby::Event::Resize(width: 80, height: 24)
      matched = true
    else
      matched = false
    end

    assert matched, "Should match Event::Resize"
  end
end
