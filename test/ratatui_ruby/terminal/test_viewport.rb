# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"
require "minitest/autorun"

class TestViewport < Minitest::Test
  def test_fullscreen_factory_creates_fullscreen_viewport
    viewport = RatatuiRuby::Terminal::Viewport.fullscreen

    assert_equal :fullscreen, viewport.type
  end

  def test_inline_factory_creates_inline_viewport_with_height
    viewport = RatatuiRuby::Terminal::Viewport.inline(8)

    assert_equal :inline, viewport.type
    assert_equal 8, viewport.height
  end

  def test_fullscreen_predicate_returns_true_for_fullscreen
    viewport = RatatuiRuby::Terminal::Viewport.fullscreen

    assert viewport.fullscreen?
  end

  def test_inline_predicate_returns_true_for_inline
    viewport = RatatuiRuby::Terminal::Viewport.inline(5)

    assert viewport.inline?
  end
end
