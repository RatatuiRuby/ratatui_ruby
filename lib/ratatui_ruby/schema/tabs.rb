# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a set of tabs, one of which is selected.
  #
  # [titles] Array of strings or lines to display as tab titles.
  # [selected_index] The index of the currently selected tab.
  # [block] Optional block widget to wrap the tabs.
  class Tabs < Data.define(:titles, :selected_index, :block)
    # Creates a new Tabs widget.
    #
    # [titles] Array of strings or lines to display as tab titles.
    # [selected_index] The index of the currently selected tab.
    # [block] Optional block widget to wrap the tabs.
    def initialize(titles: [], selected_index: 0, block: nil)
      super
    end
  end
end
