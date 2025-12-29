# frozen_string_literal: true
#
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require_relative "../../lib/ratatui_ruby/event"

class TestEventPatternMatching < Minitest::Test
  def test_key_pattern_matching
    event = RatatuiRuby::Event::Key.new(code: "q", modifiers: ["ctrl"])
    
    case event
    in type: :key, code: "q", modifiers: ["ctrl"]
      assert true
    else
      flunk "Key event did not match"
    end
  end

  def test_mouse_pattern_matching
    event = RatatuiRuby::Event::Mouse.new(kind: "down", x: 10, y: 5, button: "left")
    
    case event
    in type: :mouse, kind: "down", x: 10, y: 5, button: "left"
      assert true
    else
      flunk "Mouse event did not match"
    end
  end

  def test_resize_pattern_matching
    event = RatatuiRuby::Event::Resize.new(width: 80, height: 24)
    
    case event
    in type: :resize, width: 80, height: 24
      assert true
    else
      flunk "Resize event did not match"
    end
  end

  def test_paste_pattern_matching
    event = RatatuiRuby::Event::Paste.new(content: "hello")
    
    case event
    in type: :paste, content: "hello"
      assert true
    else
      flunk "Paste event did not match"
    end
  end

  def test_focus_gained_pattern_matching
    event = RatatuiRuby::Event::FocusGained.new
    
    case event
    in type: :focus_gained
      assert true
    else
      flunk "FocusGained event did not match"
    end
  end

  def test_focus_lost_pattern_matching
    event = RatatuiRuby::Event::FocusLost.new
    
    case event
    in type: :focus_lost
      assert true
    else
      flunk "FocusLost event did not match"
    end
  end
end
