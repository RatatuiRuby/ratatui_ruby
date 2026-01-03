# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTestHelperStyleAssertions < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_assert_fg_and_bg_order
    with_test_terminal(20, 3) do
      # Render text with specific colors
      style = RatatuiRuby::Style.new(fg: :red, bg: :blue)
      widget = RatatuiRuby::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      # Should pass with expected value first
      assert_fg(:red, 0, 0)
      assert_bg(:blue, 0, 0)

      # Should fail if order is wrong or color is wrong
      assert_raises(TypeError) { assert_fg(0, 0, :red) }
      assert_raises(Minitest::Assertion) { assert_fg(:blue, 0, 0) }
    end
  end

  def test_metaprogrammed_color_assertions
    with_test_terminal(20, 3) do
      style = RatatuiRuby::Style.new(fg: :green, bg: :yellow)
      widget = RatatuiRuby::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      # Test foreground metaprogrammed methods
      assert_green(0, 0)
      assert_bg_yellow(0, 0)

      # Test failure cases
      assert_raises(Minitest::Assertion) { assert_red(0, 0) }
      assert_raises(Minitest::Assertion) { assert_bg_blue(0, 0) }
    end
  end

  def test_modifier_assertions
    with_test_terminal(20, 3) do
      style = RatatuiRuby::Style.new(modifiers: [:bold, :italic, :underlined])
      widget = RatatuiRuby::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      assert_bold(0, 0)
      assert_italic(0, 0)
      assert_underlined(0, 0)
      assert_underline(0, 0) # Alias

      # Negation check
      assert_raises(Minitest::Assertion) { assert_dim(0, 0) }
    end
  end

  def test_other_modifier_aliases
    with_test_terminal(20, 3) do
      style = RatatuiRuby::Style.new(modifiers: [:reversed, :crossed_out, :slow_blink, :hidden])
      widget = RatatuiRuby::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      assert_reversed(0, 0)
      assert_inverse(0, 0)
      assert_inverse_video(0, 0)

      assert_crossed_out(0, 0)
      assert_strikethrough(0, 0)
      assert_strike(0, 0)

      assert_slow_blink(0, 0)
      assert_blink(0, 0)

      assert_hidden(0, 0)
    end
  end
end
