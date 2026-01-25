# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "ratatui_ruby"

# Catalog of all key predicates sourced from Rust + Ruby generation.
class PredicateCatalog < Data.define(:base_keys, :media_keys, :modifier_keys, :keyboard_modifiers)
  # ASCII printable characters that can be RBS method names (with backtick escaping)
  # Excludes: space (0x20), backtick (`), and characters that break RBS parser (:, etc.)
  RBS_INCOMPATIBLE = %w[` :].freeze
  CHARACTERS = (0x21..0x7E).map(&:chr).reject { |c| RBS_INCOMPATIBLE.include?(c) }.freeze
  # Function keys F1-F24 (conventional terminal range)
  FUNCTION_KEYS = (1..24).map { |n| "f#{n}" }.freeze

  def self.new
    data = RatatuiRuby._all_key_codes
    super(
      base_keys: data[:base_keys],
      media_keys: data[:media_keys],
      modifier_keys: data[:modifier_keys],
      keyboard_modifiers: data[:keyboard_modifiers]
    )
  end

  def characters = CHARACTERS
  def function_keys = FUNCTION_KEYS

  def all_base_codes
    base_keys + media_keys + modifier_keys + characters + function_keys
  end

  def modifier_combinations
    mods = keyboard_modifiers.sort # Modifiers are stored sorted alphabetically
    one = mods.map { |m| [m] }
    two = mods.combination(2).map(&:sort)
    three = mods.combination(3).map(&:sort)
    one + two + three
  end

  def all_predicates
    simple = all_base_codes
    combined = modifier_combinations.flat_map do |combo|
      prefix = combo.join("_")
      all_base_codes.map { |key| "#{prefix}_#{key}" }
    end
    simple + combined
  end
end
