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
