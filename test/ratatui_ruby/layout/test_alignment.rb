# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestAlignment < Minitest::Test
  def test_horizontal_alignment_left
    assert_equal :left, RatatuiRuby::Layout::HorizontalAlignment::LEFT
  end

  def test_horizontal_alignment_center
    assert_equal :center, RatatuiRuby::Layout::HorizontalAlignment::CENTER
  end

  def test_horizontal_alignment_right
    assert_equal :right, RatatuiRuby::Layout::HorizontalAlignment::RIGHT
  end

  def test_horizontal_alignment_all
    expected = [:left, :center, :right]
    assert_equal expected, RatatuiRuby::Layout::HorizontalAlignment::ALL
    assert RatatuiRuby::Layout::HorizontalAlignment::ALL.frozen?
  end

  def test_vertical_alignment_top
    assert_equal :top, RatatuiRuby::Layout::VerticalAlignment::TOP
  end

  def test_vertical_alignment_center
    assert_equal :center, RatatuiRuby::Layout::VerticalAlignment::CENTER
  end

  def test_vertical_alignment_bottom
    assert_equal :bottom, RatatuiRuby::Layout::VerticalAlignment::BOTTOM
  end

  def test_vertical_alignment_all
    expected = [:top, :center, :bottom]
    assert_equal expected, RatatuiRuby::Layout::VerticalAlignment::ALL
    assert RatatuiRuby::Layout::VerticalAlignment::ALL.frozen?
  end

  def test_alignment_is_alias_for_horizontal
    assert_same RatatuiRuby::Layout::HorizontalAlignment, RatatuiRuby::Layout::Alignment
    assert_equal :center, RatatuiRuby::Layout::Alignment::CENTER
  end
end
