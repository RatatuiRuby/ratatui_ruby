# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a set of tabs, one of which is selected.
  #
  # [titles] Array of strings or lines to display as tab titles.
  # [selected_index] The index of the currently selected tab.
  # [divider] String to use as a separator between tabs.
  # [highlight_style] Style to apply to the selected tab title.
  class Tabs < Data.define(:titles, :selected_index, :block, :divider, :highlight_style)
    # Creates a new Tabs widget.
    #
    # [titles] Array of strings or lines to display as tab titles.
    # [selected_index] The index of the currently selected tab.
    # [block] Optional block widget to wrap the tabs.
    # [divider] String to use as a separator between tabs.
    # [highlight_style] Style to apply to the selected tab title.
    def initialize(titles: [], selected_index: 0, block: nil, divider: nil, highlight_style: nil)
      super
    end
  end
end
