# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A scrollable list of items.
  #
  # [items] an array of strings to display.
  # [selected_index] the index of the currently selected item (Integer or nil).
  # [block] an optional Block widget to wrap the list.
  class List < Data.define(:items, :selected_index, :block)
    # Creates a new List.
    def initialize(items: [], selected_index: nil, block: nil)
      super
    end
  end
end
