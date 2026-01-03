# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestStyle < Minitest::Test
  def test_style_creation
    s = RatatuiRuby::Style::Style.new(fg: :red, bg: :blue, modifiers: [:bold])
    assert_equal :red, s.fg
    assert_equal :blue, s.bg
    assert_equal [:bold], s.modifiers
  end

  def test_style_creation_with_integers
    # 5 is Magenta in Xterm 256
    s = RatatuiRuby::Style::Style.new(fg: 5, bg: 10)
    assert_equal 5, s.fg
    assert_equal 10, s.bg
  end
end
