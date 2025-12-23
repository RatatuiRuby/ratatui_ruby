# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a list of selectable items.
  #
  # [items] An array of strings to display in the list.
  # [selected_index] The index of the currently selected item, or nil if none.
  # [style] The base style for all items.
  # [highlight_style] The style for the selected item.
  # [highlight_symbol] The symbol to display in front of the selected item.
  # [block] An optional Block widget to wrap the list.
  class List < Data.define(:items, :selected_index, :style, :highlight_style, :highlight_symbol, :block)
    # Creates a new List.
    #
    # [items] An array of strings to display in the list.
    # [selected_index] The index of the currently selected item, or nil if none.
    # [style] The base style for all items.
    # [highlight_style] The style for the selected item.
    # [highlight_symbol] The symbol to display in front of the selected item.
    # [block] An optional Block widget to wrap the list.
    def initialize(items: [], selected_index: nil, style: nil, highlight_style: nil, highlight_symbol: "> ", block: nil)
      super
    end
  end
end
