# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestShadeSymbols < Minitest::Test
  # v1.0.0 alignment: Symbols::Shade constants
  # Ratatui provides symbols::shade constants for shaded block characters.
  # These are useful for creating gradient effects or filling areas with
  # various densities.

  def test_shade_empty
    # EMPTY is a space character - lowest density
    assert_equal " ", RatatuiRuby::Symbols::Shade::EMPTY
  end

  def test_shade_light
    # LIGHT shading character - 25% density
    assert_equal "░", RatatuiRuby::Symbols::Shade::LIGHT
  end

  def test_shade_medium
    # MEDIUM shading character - 50% density
    assert_equal "▒", RatatuiRuby::Symbols::Shade::MEDIUM
  end

  def test_shade_dark
    # DARK shading character - 75% density
    assert_equal "▓", RatatuiRuby::Symbols::Shade::DARK
  end

  def test_shade_full
    # FULL block character - 100% density
    assert_equal "█", RatatuiRuby::Symbols::Shade::FULL
  end

  def test_all_shades_are_strings_and_frozen
    [
      RatatuiRuby::Symbols::Shade::EMPTY,
      RatatuiRuby::Symbols::Shade::LIGHT,
      RatatuiRuby::Symbols::Shade::MEDIUM,
      RatatuiRuby::Symbols::Shade::DARK,
      RatatuiRuby::Symbols::Shade::FULL,
    ].each do |shade|
      assert_kind_of String, shade
      assert shade.frozen?, "Shade constant should be frozen"
    end
  end
end

class TestLineSymbols < Minitest::Test
  # v1.0.0 alignment: Symbols::Line constants
  # Ratatui provides symbols::line for box-drawing characters.
  # Used internally for Block borders but also useful for custom drawing.

  # Individual line character constants
  def test_vertical
    assert_equal "│", RatatuiRuby::Symbols::Line::VERTICAL
  end

  def test_horizontal
    assert_equal "─", RatatuiRuby::Symbols::Line::HORIZONTAL
  end

  def test_top_right
    assert_equal "┐", RatatuiRuby::Symbols::Line::TOP_RIGHT
  end

  def test_top_left
    assert_equal "┌", RatatuiRuby::Symbols::Line::TOP_LEFT
  end

  def test_bottom_right
    assert_equal "┘", RatatuiRuby::Symbols::Line::BOTTOM_RIGHT
  end

  def test_bottom_left
    assert_equal "└", RatatuiRuby::Symbols::Line::BOTTOM_LEFT
  end

  def test_cross
    assert_equal "┼", RatatuiRuby::Symbols::Line::CROSS
  end

  # Predefined sets
  def test_normal_set_is_frozen_hash
    set = RatatuiRuby::Symbols::Line::NORMAL
    assert_kind_of Hash, set
    assert set.frozen?, "NORMAL set should be frozen"
  end

  def test_normal_set_contains_expected_keys
    set = RatatuiRuby::Symbols::Line::NORMAL
    expected_keys = %i[
      vertical
      horizontal
      top_right
      top_left
      bottom_right
      bottom_left
      vertical_left
      vertical_right
      horizontal_down
      horizontal_up
      cross
]
    expected_keys.each do |key|
      assert set.key?(key), "NORMAL set should contain #{key.inspect}"
    end
  end

  def test_normal_set_values
    set = RatatuiRuby::Symbols::Line::NORMAL
    assert_equal "│", set[:vertical]
    assert_equal "─", set[:horizontal]
    assert_equal "┐", set[:top_right]
    assert_equal "┌", set[:top_left]
    assert_equal "┘", set[:bottom_right]
    assert_equal "└", set[:bottom_left]
  end

  def test_rounded_set_has_rounded_corners
    set = RatatuiRuby::Symbols::Line::ROUNDED
    assert_equal "╮", set[:top_right]
    assert_equal "╭", set[:top_left]
    assert_equal "╯", set[:bottom_right]
    assert_equal "╰", set[:bottom_left]
    # Other values same as NORMAL
    assert_equal "│", set[:vertical]
    assert_equal "─", set[:horizontal]
  end

  def test_double_set_uses_double_characters
    set = RatatuiRuby::Symbols::Line::DOUBLE
    assert_equal "║", set[:vertical]
    assert_equal "═", set[:horizontal]
    assert_equal "╗", set[:top_right]
    assert_equal "╔", set[:top_left]
    assert_equal "╝", set[:bottom_right]
    assert_equal "╚", set[:bottom_left]
  end

  def test_thick_set_uses_thick_characters
    set = RatatuiRuby::Symbols::Line::THICK
    assert_equal "┃", set[:vertical]
    assert_equal "━", set[:horizontal]
    assert_equal "┓", set[:top_right]
    assert_equal "┏", set[:top_left]
    assert_equal "┛", set[:bottom_right]
    assert_equal "┗", set[:bottom_left]
  end

  def test_all_sets_are_frozen
    [
      RatatuiRuby::Symbols::Line::NORMAL,
      RatatuiRuby::Symbols::Line::ROUNDED,
      RatatuiRuby::Symbols::Line::DOUBLE,
      RatatuiRuby::Symbols::Line::THICK,
    ].each do |set|
      assert set.frozen?, "Line set should be frozen"
    end
  end
end

class TestBarSymbols < Minitest::Test
  # v1.0.0 alignment: Symbols::Bar constants
  # Ratatui provides symbols::bar for vertical bar characters.
  # Used by Sparkline widget for rendering data values as bars.

  # Individual bar character constants
  def test_full
    assert_equal "█", RatatuiRuby::Symbols::Bar::FULL
  end

  def test_seven_eighths
    assert_equal "▇", RatatuiRuby::Symbols::Bar::SEVEN_EIGHTHS
  end

  def test_three_quarters
    assert_equal "▆", RatatuiRuby::Symbols::Bar::THREE_QUARTERS
  end

  def test_five_eighths
    assert_equal "▅", RatatuiRuby::Symbols::Bar::FIVE_EIGHTHS
  end

  def test_half
    assert_equal "▄", RatatuiRuby::Symbols::Bar::HALF
  end

  def test_three_eighths
    assert_equal "▃", RatatuiRuby::Symbols::Bar::THREE_EIGHTHS
  end

  def test_one_quarter
    assert_equal "▂", RatatuiRuby::Symbols::Bar::ONE_QUARTER
  end

  def test_one_eighth
    assert_equal "▁", RatatuiRuby::Symbols::Bar::ONE_EIGHTH
  end

  # Predefined sets
  def test_nine_levels_set_is_frozen_hash
    set = RatatuiRuby::Symbols::Bar::NINE_LEVELS
    assert_kind_of Hash, set
    assert set.frozen?, "NINE_LEVELS set should be frozen"
  end

  def test_nine_levels_set_contains_expected_keys
    set = RatatuiRuby::Symbols::Bar::NINE_LEVELS
    expected_keys = %i[
      full
      seven_eighths
      three_quarters
      five_eighths
      half
      three_eighths
      one_quarter
      one_eighth
      empty
]
    expected_keys.each do |key|
      assert set.key?(key), "NINE_LEVELS set should contain #{key.inspect}"
    end
  end

  def test_nine_levels_uses_distinct_levels
    set = RatatuiRuby::Symbols::Bar::NINE_LEVELS
    assert_equal "█", set[:full]
    assert_equal "▇", set[:seven_eighths]
    assert_equal "▆", set[:three_quarters]
    assert_equal "▅", set[:five_eighths]
    assert_equal "▄", set[:half]
    assert_equal "▃", set[:three_eighths]
    assert_equal "▂", set[:one_quarter]
    assert_equal "▁", set[:one_eighth]
    assert_equal " ", set[:empty]
  end

  def test_three_levels_collapses_to_three
    set = RatatuiRuby::Symbols::Bar::THREE_LEVELS
    # THREE_LEVELS collapses 9 levels to 3: full, half, empty
    assert_equal "█", set[:full]
    assert_equal "█", set[:seven_eighths] # collapsed to full
    assert_equal "▄", set[:three_quarters] # collapsed to half
    assert_equal "▄", set[:half]
    assert_equal " ", set[:one_eighth] # collapsed to empty
    assert_equal " ", set[:empty]
  end

  def test_all_sets_are_frozen
    [
      RatatuiRuby::Symbols::Bar::THREE_LEVELS,
      RatatuiRuby::Symbols::Bar::NINE_LEVELS,
    ].each do |set|
      assert set.frozen?, "Bar set should be frozen"
    end
  end
end

class TestBlockSymbols < Minitest::Test
  # v1.0.0 alignment: Symbols::Block constants
  # Ratatui provides symbols::block for horizontal block characters.
  # Used by Gauge widget for rendering fill from left to right.
  # Note: Different from Bar which uses vertical fill (bottom to top).

  # Individual block character constants
  def test_full
    assert_equal "█", RatatuiRuby::Symbols::Block::FULL
  end

  def test_seven_eighths
    # Block uses different characters from Bar - horizontal not vertical
    assert_equal "▉", RatatuiRuby::Symbols::Block::SEVEN_EIGHTHS
  end

  def test_three_quarters
    assert_equal "▊", RatatuiRuby::Symbols::Block::THREE_QUARTERS
  end

  def test_five_eighths
    assert_equal "▋", RatatuiRuby::Symbols::Block::FIVE_EIGHTHS
  end

  def test_half
    assert_equal "▌", RatatuiRuby::Symbols::Block::HALF
  end

  def test_three_eighths
    assert_equal "▍", RatatuiRuby::Symbols::Block::THREE_EIGHTHS
  end

  def test_one_quarter
    assert_equal "▎", RatatuiRuby::Symbols::Block::ONE_QUARTER
  end

  def test_one_eighth
    assert_equal "▏", RatatuiRuby::Symbols::Block::ONE_EIGHTH
  end

  # Predefined sets
  def test_nine_levels_set_is_frozen_hash
    set = RatatuiRuby::Symbols::Block::NINE_LEVELS
    assert_kind_of Hash, set
    assert set.frozen?, "NINE_LEVELS set should be frozen"
  end

  def test_nine_levels_uses_distinct_levels
    set = RatatuiRuby::Symbols::Block::NINE_LEVELS
    assert_equal "█", set[:full]
    assert_equal "▉", set[:seven_eighths]
    assert_equal "▊", set[:three_quarters]
    assert_equal "▋", set[:five_eighths]
    assert_equal "▌", set[:half]
    assert_equal "▍", set[:three_eighths]
    assert_equal "▎", set[:one_quarter]
    assert_equal "▏", set[:one_eighth]
    assert_equal " ", set[:empty]
  end

  def test_three_levels_collapses_to_three
    set = RatatuiRuby::Symbols::Block::THREE_LEVELS
    assert_equal "█", set[:full]
    assert_equal "█", set[:seven_eighths] # collapsed to full
    assert_equal "▌", set[:three_quarters] # collapsed to half
    assert_equal "▌", set[:half]
    assert_equal " ", set[:one_eighth] # collapsed to empty
    assert_equal " ", set[:empty]
  end

  def test_all_sets_are_frozen
    [
      RatatuiRuby::Symbols::Block::THREE_LEVELS,
      RatatuiRuby::Symbols::Block::NINE_LEVELS,
    ].each do |set|
      assert set.frozen?, "Block set should be frozen"
    end
  end
end

class TestScrollbarSymbols < Minitest::Test
  # v1.0.0 alignment: Symbols::Scrollbar constants
  # Ratatui provides symbols::scrollbar for scrollbar widget characters.
  # Each set provides track, thumb, begin, and end characters.

  # Predefined sets
  def test_vertical_set_is_frozen_hash
    set = RatatuiRuby::Symbols::Scrollbar::VERTICAL
    assert_kind_of Hash, set
    assert set.frozen?, "VERTICAL set should be frozen"
  end

  def test_vertical_set_contains_expected_keys
    set = RatatuiRuby::Symbols::Scrollbar::VERTICAL
    expected_keys = %i[track thumb begin_char end_char]
    expected_keys.each do |key|
      assert set.key?(key), "VERTICAL set should contain #{key.inspect}"
    end
  end

  def test_vertical_set_uses_single_line_characters
    set = RatatuiRuby::Symbols::Scrollbar::VERTICAL
    assert_equal "│", set[:track]
    assert_equal "█", set[:thumb]
    assert_equal "↑", set[:begin_char]
    assert_equal "↓", set[:end_char]
  end

  def test_double_vertical_set_uses_double_line_characters
    set = RatatuiRuby::Symbols::Scrollbar::DOUBLE_VERTICAL
    assert_equal "║", set[:track]
    assert_equal "█", set[:thumb]
    assert_equal "▲", set[:begin_char]
    assert_equal "▼", set[:end_char]
  end

  def test_horizontal_set_uses_single_line_characters
    set = RatatuiRuby::Symbols::Scrollbar::HORIZONTAL
    assert_equal "─", set[:track]
    assert_equal "█", set[:thumb]
    assert_equal "←", set[:begin_char]
    assert_equal "→", set[:end_char]
  end

  def test_double_horizontal_set_uses_double_line_characters
    set = RatatuiRuby::Symbols::Scrollbar::DOUBLE_HORIZONTAL
    assert_equal "═", set[:track]
    assert_equal "█", set[:thumb]
    assert_equal "◄", set[:begin_char]
    assert_equal "►", set[:end_char]
  end

  def test_all_sets_are_frozen
    [
      RatatuiRuby::Symbols::Scrollbar::VERTICAL,
      RatatuiRuby::Symbols::Scrollbar::DOUBLE_VERTICAL,
      RatatuiRuby::Symbols::Scrollbar::HORIZONTAL,
      RatatuiRuby::Symbols::Scrollbar::DOUBLE_HORIZONTAL,
    ].each do |set|
      assert set.frozen?, "Scrollbar set should be frozen"
    end
  end
end
